local kernel = require("util/kernel")
local convolve_op = require("util/convolve_op")

local gaussian_blur = {}
gaussian_blur.__index = gaussian_blur

--------------------------------------------------------------------------------
-- Creates a two-pass (separated) Gaussian blur filter.
-- @param radius the standard deviation of the Gaussian distribution
-- @param offset the number of standard deviation that this kernel covers
-- @param edges the color to sample around the edges (or nil if none)

function gaussian_blur.new(radius, offset, edges)
    local self = {}
    setmetatable(self, gaussian_blur)

    self.blur_radius = radius
    self.blur_offset = offset
    self.edges = edges
    generate_gaussian_1D_convolution_kernel(self)

    return self
end

--------------------------------------------------------------------------------
-- Calculates the value of a Gaussian distribution at a given point.
-- @param sigma the standard deviation of the Gaussian distribution
-- @param x the point at which to calculate the value
-- @return the value of the Gaussian distribution at point x

function gaussian_1D(sigma, x)
    local two_sigma_sq = 2.0 * sigma * sigma
    local pi = math.pi
    return math.exp(-x * x / two_sigma_sq) / math.sqrt(two_sigma_sq * pi)
end


--------------------------------------------------------------------------------
-- Creates the necessary horizontal and vertical convolution kernels for
-- a Gaussian blur filter.

function generate_gaussian_1D_convolution_kernel(self)
    local size = self.blur_radius * 2 * self.blur_offset + 1

    local weights = {}

    -- Sample 1D Gaussian function at pixel locations
    for i = 1, size do
        local x = (i - 1) - self.blur_radius * self.blur_offset
        weights[i] = gaussian_1D(self.blur_radius, x)
    end

    -- Create two perpendicular convolution kernels (the Gaussian
    -- convolution is separable)

    -- Horizontal
    local hconv_kernel = kernel.new(size, 1, weights)
    self.hblur = convolve_op.new(hconv_kernel)

    -- Vertical
    local vconv_kernel = kernel.new(1, size, weights)
    self.vblur = convolve_op.new(vconv_kernel)
end


--------------------------------------------------------------------------------
-- A helper function which generates a blurred background of the screen
-- before the modal window is drawn on top.
-- @param src the source screen buffer to blur
-- @return the resultant blurred screen buffer

function gaussian_blur:apply(src)

    local w = src:getWidth()
    local h = src:getHeight()

    local pad_buffer, hblur_buffer

    if self.edges ~= nil then
        -- Calculate edge offset
        local pad = 2 * self.blur_radius * self.blur_offset

        -- Create a temporary oversized buffer for proper edge effects
        pad_buffer = love.graphics.newCanvas(w + pad, h + pad)

        -- Draw src buffer to temporary oversized buffer
        love.graphics.setCanvas(pad_buffer)
        love.graphics.setColor(self.edges)
        love.graphics.rectangle('fill', 0, 0, w + pad, h + pad)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(src, pad / 2, pad / 2)
        love.graphics.setCanvas()

        hblur_buffer = love.graphics.newCanvas(w, h + pad)
    else
        hblur_buffer = love.graphics.newCanvas(w, h)
        pad_buffer = src
    end

    -- Apply blur in two passes: horizontal and vertical
    self.hblur:filter(pad_buffer, hblur_buffer)

    local dst = love.graphics.newCanvas(w, h)
    self.vblur:filter(hblur_buffer, dst)

    return dst
end

return gaussian_blur
