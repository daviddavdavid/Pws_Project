local vec3 = {}

local G = 6.67 * (10^-11)

function vec3.getDeltaxyz(x1, x2, y1, y2, z1 ,z2)
	return x1 - x2, y1 - y2, z1 - z2
end

function vec3.getDistance(dx, dy, dz)
	return math.sqrt((dx^2)+(dy^2)+(dz^2))
end

function vec3.getGravity(m1, m2, r)
	if r == 0 then
        return 0
	end
	
	local F = (G * m1 * m2) / (r^2)
    return F
end

function vec3.makeVector(dx, dy, dz)
	return {dx, dy, dz}
end

function vec3.getAcceleration(m, dx,dy,dz, Fz, r)
	--(m * kg * m / s^2) / (m * kg) = m/s^2

    local acceleration_x = dx * Fz / (r * m)
    local acceleration_y = dy * Fz / (r * m)
    local acceleration_z = dz * Fz / (r * m)

    local acceleration_vector = {acceleration_x, acceleration_y, acceleration_z}

    return acceleration_vector
end

function vec3.addVectors(vectorArray)
	local final_vectors = {}
	for i,v in ipairs(vectorArray) do
		local x = 0
		local y = 0
		local z = 0

		for j,k in ipairs(v) do
			x += k[1]
			y += k[2]
			z += k[3]
		end
		
		final_vectors[i] = {x, y, z}
		
	end	
	print(final_vectors)
	return final_vectors
end




return vec3
