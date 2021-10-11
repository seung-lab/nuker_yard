import torch
import torchvision
from torch import nn
from torch.autograd import Variable
import torch.nn.functional as F
from torchvision import transforms
import torch.optim as optim
import numpy as np

# helper operations
def conv3x3(in_channels, out_channels):
    return nn.Conv2d(in_channels, out_channels,
        kernel_size=3, stride=1, padding=1, bias=True)
        #kernel_size=5, stride=1, padding=2, bias=True)

def maxpool2x2():
    return nn.MaxPool2d(kernel_size=2, stride=2, padding=0)

class UpConv2x2(nn.Module):
    def __init__(self, channels, bn = True, momentum = 0.001):
        super(UpConv2x2, self).__init__()
        self.upsample = nn.Upsample(scale_factor=2)
        self.conv = nn.Conv2d(channels, channels // 2,
            kernel_size=2, stride=1, padding=0, bias=True)
        self.bn = bn
        if self.bn:
            #print('batchNorm = True')
            self.bn1 = nn.BatchNorm2d(channels//2, momentum=momentum)

    def forward(self, x):
        x = self.upsample(x)
        x = F.pad(x, (0,1,0,1))
        x = self.conv(x)
        if self.bn:
            x = self.bn1(x)
        return x

def concat(xh, xv):
    return torch.cat([xh, xv], dim=1)


# unet blocks
class ConvBlock(nn.Module):
    def __init__(self, in_channels, out_channels, cytoplasm = True, bn = True, momentum = 0.001, down_path = False):
        """
        Args:
            in_channels: number of channels in input (1st) feature map
            out_channels: number of channels in output feature maps
        """
        super(ConvBlock, self).__init__()
        self.conv1 = conv3x3(in_channels, out_channels)
        self.cytoplasm = cytoplasm
        if down_path == True and self.cytoplasm == True:
            self.conv2 = conv3x3(out_channels, out_channels-1)
        else:
            self.conv2 = conv3x3(out_channels, out_channels)
        self.bn = bn
        #print('batchNorm =', bn)

        if self.bn:
            #print('batchNorm = True')
            self.bn1 = nn.BatchNorm2d(out_channels, momentum=momentum)
            self.bn2 = nn.BatchNorm2d(out_channels, momentum=momentum)

    def forward(self, x):
        out1 = self.conv1(x)
        #out1 = F.relu(out1)
        if self.bn:
            out1 = self.bn1(out1)
        out1 = F.relu(out1)
        #out1 = F.softmax(out1, dim=1)

        out2 = self.conv2(out1)
        if self.bn:
            out2 = self.bn2(out2)
        out2 = F.relu(out2)
        #out2 = F.softmax(out2, dim=1)
        return out2

class ChainableSingleConvCombo(nn.Module):
    def __init__(self, in_channels, out_channels, kernel_size = 3, dilation = 1,
                relu = False, bn = False, bn_momentum = 0.001, softmax = False,
                post_module = None):
        """
        Args:
            in_channels: number of channels in input (1st) feature map
            out_channels: number of channels in output feature maps
        """
        super(ChainableSingleConvCombo, self).__init__()
        self.conv1 = nn.Conv2d(in_channels, out_channels,
                kernel_size=kernel_size, stride=1, padding=(kernel_size//2)*dilation, bias=True, dilation=dilation)
        self.bn = bn
        self.relu = relu
        self.softmax = softmax
        self.post_module = post_module

        if self.bn:
            self.bn1 = nn.BatchNorm2d(out_channels, momentum=momentum)

    def forward(self, x):
        out1 = self.conv1(x)

        if self.relu:
            out1 = F.relu(out1)

        if self.bn:
            out1 = self.bn1(out1)
        
        if self.softmax:
            out1 = F.softmax(out1, dim=1)

        if self.post_module is not None:
            out1 = self.post_module(out1)

        return out1

class ConvBlockNoRelu(nn.Module):
    def __init__(self, in_channels, out_channels, cytoplasm = True, bn = True, momentum = 0.001, down_path = False):
        """
        Args:
            in_channels: number of channels in input (1st) feature map
            out_channels: number of channels in output feature maps
        """
        super(ConvBlockNoRelu, self).__init__()
        self.conv1 = conv3x3(in_channels, out_channels)
        self.cytoplasm = cytoplasm
        # if down_path == True and self.cytoplasm == True:
        #     self.conv2 = conv3x3(out_channels, out_channels-1)
        # else:
        #     self.conv2 = conv3x3(out_channels, out_channels)
        self.bn = bn
        #print('batchNorm =', bn)

        if self.bn:
            #print('batchNorm = True')
            self.bn1 = nn.BatchNorm2d(out_channels, momentum=momentum)
            #self.bn2 = nn.BatchNorm2d(out_channels, momentum=momentum)

    def forward(self, x):
        out1 = self.conv1(x)
        if self.bn:
            out1 = self.bn1(out1)
        #out1 = F.relu(out1)

        #out2 = F.relu(out2)
        return out1

class ConvRelu(nn.Module):
    def __init__(self, in_channels, out_channels, kernel_size = 7, dilation = 8, bn = True, momentum = 0.001, softmax = False):
        super(ConvRelu, self).__init__()
        
        self.conv1 = nn.Conv2d(in_channels, out_channels,
                kernel_size=kernel_size, stride=1, padding=(kernel_size//2)*dilation, bias=True, dilation=dilation)
        self.conv2 = nn.Conv2d(out_channels, out_channels,
                kernel_size=kernel_size, stride=1, padding=(kernel_size//2)*dilation, bias=True, dilation=dilation)
        self.bn = bn
        #print('batchNorm =', bn)
        self.softmax = softmax

        if self.bn:
            #print('batchNorm = True')
            self.bn1 = nn.BatchNorm2d(out_channels, momentum=momentum)
            self.bn2 = nn.BatchNorm2d(out_channels, momentum=momentum)

    def forward(self, x):
        out1 = self.conv1(x)
        if self.bn:
            out1 = self.bn1(out1)
        #out1 = F.relu(out1)

        out2 = self.conv2(out1)
        if self.bn:
            out2 = self.bn2(out2)
        #out2 = F.relu(out2)
        #print(out1.shape, out2.shape)
        return out2

class DownConvBlock(nn.Module):
    def __init__(self, in_channels, out_channels, cytoplasm = True, bn = True, momentum = 0.001):
        """
        Args:
            in_channels: number of channels in input (1st) feature map
            out_channels: number of channels in output feature maps
        """
        super(DownConvBlock, self).__init__()
        self.downsample = maxpool2x2()
        self.cytoplasm = cytoplasm
        self.convs = ConvBlock(in_channels, out_channels, self.cytoplasm, bn, momentum, True)

    def forward(self, x):
        x_down = self.downsample(x)
        x_depth = x_down.shape[1] - 1
        nuc_mask = x_down[:,[x_depth],:,:] ## last layer of x is downsampled nucleus mask. Store this for later concatenation
        x_conv = self.convs(x_down)
        if self.cytoplasm == True:
            x_out = concat(x_conv, nuc_mask)
        else:
            x_out = x_conv
        return x_out

class UpConvBlock(nn.Module):
    def __init__(self, in_channels, out_channels, bn = True, momentum = 0.001):
        """
        Args:
            in_channels: number of channels in input (1st) feature map
            out_channels: number of channels in output feature maps
        """
        super(UpConvBlock, self).__init__()
        self.upconv = UpConv2x2(in_channels, bn, momentum)
        
        #print('batchNorm =', bn)
        self.convs = ConvBlock(in_channels, out_channels, False, bn, momentum)

    def forward(self, xh, xv):
        """
        Args:
            xh: torch Variable, activations from same resolution feature maps (gray arrow in diagram)
            xv: torch Variable, activations from lower resolution feature maps (green arrow in diagram)
        """
        x = self.upconv(xv)
        x = concat(xh, x)
        x = self.convs(x)
        return x

class UNet(nn.Module):
    def __init__(self, n_classes=1, cytoplasm = True, bn = True, momentum = 0.001, n_levels=4, bottomconv=False, normlayer = False):
        super(UNet, self).__init__()
        fs = [16,32,64,128,256,512]
        self.bn = bn
        self.cytoplasm = cytoplasm
        self.normlayer = normlayer
        if self.normlayer is True:
            #self.conv_inpre = ConvRelu(1, fs[0], kernel_size=15, dilation=8, bn = bn, momentum = momentum)
            #self.conv_inpre = ConvRelu(1, fs[0], kernel_size=15, dilation=1, bn = False, momentum = momentum, softmax = True)
            self.conv_inpre = ChainableSingleConvCombo(1, fs[0], kernel_size=15, dilation=1,
                    post_module = 
                    ChainableSingleConvCombo(fs[0], fs[0], kernel_size=15, dilation=1,
                    softmax = True,
                    post_module = None)
                    )
            self.conv_in = ConvBlock(fs[0], fs[0], self.cytoplasm, bn, momentum, True)
        else:
            self.conv_in = ConvBlock(1, fs[0], self.cytoplasm, bn, momentum, True)
        self.dconv1 = DownConvBlock(fs[0], fs[1], self.cytoplasm, bn, momentum)
        self.dconv2 = DownConvBlock(fs[1], fs[2], self.cytoplasm, bn, momentum)
        self.dconv3 = DownConvBlock(fs[2], fs[3], self.cytoplasm, bn, momentum)
        self.dconv4 = DownConvBlock(fs[3], fs[4], self.cytoplasm, bn, momentum)

        self.bottom = bottomconv;
        if self.bottom is True:
            self.bottomconv = conv3x3(fs[4], fs[4])
            if self.bn:
                self.bottombn = nn.BatchNorm2d(fs[4], momentum=momentum)

        self.n_levels = n_levels
        if n_levels==5:
            self.dconv5 = DownConvBlock(fs[4], fs[5], self.cytoplasm, bn, momentum)
            self.uconv5 = UpConvBlock(fs[5], fs[4], bn, momentum)
        self.uconv1 = UpConvBlock(fs[4], fs[3], bn, momentum)
        self.uconv2 = UpConvBlock(fs[3], fs[2], bn, momentum)
        self.uconv3 = UpConvBlock(fs[2], fs[1], bn, momentum)
        self.uconv4 = UpConvBlock(fs[1], fs[0], bn, momentum)
        self.conv_out = conv3x3(fs[0], n_classes)
        self._initialize_weights()
        if self.normlayer is True:
            self.weight_init_prenorm(self.conv_inpre)

    def forward(self, x, nuc_mask = None):
        if self.normlayer is True:
            xd0 = self.conv_inpre(x)
            xd0 = self.conv_in(xd0)
        else:
            xd0 = self.conv_in(x)
        # Add nucleus mask as last feature map before first downsampling
        if self.cytoplasm == True:
            xd0 = concat(xd0, nuc_mask)
        xd1 = self.dconv1(xd0)
        xd2 = self.dconv2(xd1)
        xd3 = self.dconv3(xd2)
        xd4 = self.dconv4(xd3)

        if self.bottom is True:
            xd4 = self.bottomconv(xd4)
            if self.bn:
                xd4 = self.bottombn(xd4)
            xd4 = F.relu(xd4)

        xu4 = xd4
        if self.n_levels == 5:
            xd5 = self.dconv5(xd4)
            xu5 = xd5;
            xu4 = self.uconv5(xd4, xu5)
        xu3 = self.uconv1(xd3, xu4)
        xu2 = self.uconv2(xd2, xu3)
        xu1 = self.uconv3(xd1, xu2)
        xu0 = self.uconv4(xd0, xu1)
        x = self.conv_out(xu0)
        return x

    def _initialize_weights(self):
        conv_modules = [m for m in self.modules() if isinstance(m, nn.Conv2d)]
        for m in conv_modules:
            self.weight_init(m)

    @staticmethod
    def weight_init(m):
        #print(m.weight.size)
        #print(m.weight.size(0), m.weight.size(1), m.weight.size(2), m.weight.size(3))
        m.weight.data.normal_(0, np.sqrt(2. /(m.weight.size(1)*m.weight.size(2)*m.weight.size(3))))
        m.bias.data.fill_(0)

    @staticmethod
    def weight_init_prenorm(mp):
        conv_modules = [m for m in mp.modules() if isinstance(m, nn.Conv2d)]
        for m in conv_modules:
            print(m.weight.data.shape)
            kernel_size = m.weight.size(-1)
            m.weight.data.fill_(0)
            m.weight.data[...,kernel_size//2, kernel_size//2] = 1/m.weight.size(1) #size(1) is in_channels
            m.bias.data.fill_(0)

class NormNet(nn.Module):
    def __init__(self, bn = True, momentum = 0.001):
        super(NormNet, self).__init__()
        fs = [16];
        self.conv_inpre = ConvRelu(1, fs[0], kernel_size=15, dilation=8, bn = bn, momentum = momentum)
        #self.conv_out = ConvBlock(fs[0], 1, cytoplasm = False, bn = bn, momentum = momentum)
        self.conv_out = ConvBlockNoRelu(fs[0], 1, cytoplasm = False, bn = bn, momentum = momentum)
        self.weight_init_prenorm(self)

    def forward(self, x):
        x = self.conv_inpre(x)
        x = self.conv_out(x)
        return x

    @staticmethod
    def weight_init_prenorm(mp):
        conv_modules = [m for m in mp.modules() if isinstance(m, nn.Conv2d)]
        for m in conv_modules:
            print(m.weight.data.shape)
            kernel_size = m.weight.size(-1)
            m.weight.data.fill_(0)
            m.weight.data[...,kernel_size//2, kernel_size//2] = 1/m.weight.size(1) #size(1) is in_channels
            m.bias.data.fill_(0)

class NormUNet(nn.Module):
    def __init__(self, n_classes=1, cytoplasm = True, bn = True, momentum = 0.001, n_levels=4, bottomconv=False, normlayer = False):
        super(NormUNet, self).__init__()
        self.UNet = UNet(n_classes=n_classes, cytoplasm = cytoplasm, bn = bn, momentum = momentum,
                n_levels=n_levels, bottomconv=bottomconv, normlayer = False)
        self.NormNet = NormNet()
        
    def forward(self, x):
        x = self.NormNet(x)
        x = self.UNet(x)
        return x
