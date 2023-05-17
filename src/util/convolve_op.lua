local convolve_op = {}
convolve_op.__index = convolve_op

--------------------------------------------------------------------------------
-- Creates a GLSL shader via templating to compute a convolution with the given
-- kernel size and weights.
-- @param w the kernel width
-- @param h the kernel height
-- @param weights the table of weight data in this kernel (one-dimensional)

function make_shader(w, h, weights)
	local n = w * h

	-- Stringify weight list
	local list = "" .. weights[1]
	for i = 2, #weights do
		list = list .. ", " .. weights[i]
	end
	-- local list = table.concat(weights, ', ')

	return string.format([[#ifdef PIXEL
const int cols = %d;
const int rows = %d;
const float weights[%d] = float[%d](%s);

uniform float tex_w;
uniform float tex_h;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 sum = vec4(0.0, 0.0, 0.0, 1.0);
	float weight;
	vec2 offset;
	int hw = (cols - 1) / 2;
	int hh = (rows - 1) / 2;

	for (int y = 0; y < rows; y++) {
		for (int x = 0; x < cols; x++) {
			weight = weights[y * cols + x];
			offset.x = (x - hw) / tex_w;
			offset.y = (y - hh) / tex_h;
			sum += weight * Texel(texture, texture_coords + offset);
		}
	}

    return vec4(sum.rgb, 1.0);
}
#endif
]], w, h, n, n, list)
end

--------------------------------------------------------------------------------
-- Creates a discrete 2D convolution filter by use of OpenGL shaders.
-- @param kernel the associated kernel to operate with

function convolve_op.new(kernel)
    local self = {}
    setmetatable(self, convolve_op)

    self.kernel = kernel
    local source = make_shader(kernel.width, kernel.height, kernel.weights)
    self.shader = love.graphics.newShader(source)

    return self
end

--------------------------------------------------------------------------------
-- Applies the convolution filter on the source buffer.
-- @param src the source buffer
-- @param dst the destination buffer

function convolve_op:filter(src, dst)
	love.graphics.setCanvas(dst)
	love.graphics.setShader(self.shader)
	self.shader:send("tex_w", src:getWidth())
	self.shader:send("tex_h", src:getHeight())
	-- self.shader:send("src", src)

	-- Note: usually you should set the color to white before drawing textures
	-- but the current shader discards this color information anyway.
	-- love.graphics.setColor(255, 255, 255, 255)

	-- Calculate offset if sizes are different (src will be centered in dst)
	local ox = (dst:getWidth() - src:getWidth()) / 2
	local oy = (dst:getHeight() - src:getHeight()) / 2

	-- Note: cannot use rectangles to draw texture data! Instead we can either
	-- draw a mesh (and pass the texture as a uniform) or the texture itself
	-- love.graphics.draw(self.mesh)
	love.graphics.draw(src, ox, oy)

	love.graphics.setShader()
	love.graphics.setCanvas()
end

return convolve_op
