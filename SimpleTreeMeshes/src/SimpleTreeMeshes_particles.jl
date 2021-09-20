function test_element(tree, e_id, xp, yp)
    @assert 1 <= e_id <= tree.ne
    x, y = get_element_corner_coordinates(tree, e_id)
    d = get_element_size(tree, e_id)
    return (x <= xp <= x + d) && (y <= yp <= y + d)
end

function locate_point(tree, x, y, e_id_guess)
    if test_element(tree, e_id_guess, x, y)
       return e_id_guess
    end

    if x < tree.coordinate_offset_x || x > tree.coordinate_offset_x + tree.coordinate_scale
        error("x coordinate out of bounds")
    end

    if y < tree.coordinate_offset_y || y > tree.coordinate_offset_y + tree.coordinate_scale
        error("y coordinate out of bounds")
    end

    e_id_left = e_id_guess - 1
    e_id_right = e_id_guess + 1
    while e_id_left >= 1 || e_id_right <= tree.ne
        if e_id_left >= 1
            if test_element(tree, e_id_left, x, y)
                return e_id_left
            end
            e_id_left -= 1
        end
        if e_id_right <= tree.ne
            if test_element(tree, e_id_right, x, y)
                return e_id_right
            end
        end
        e_id_right += 1
    end
    @assert false
end;

function get_point_velocity(tree::SimpleTreeMesh, xp, yp, e_id, v)
    @assert 1 <= e_id <= tree.ne
    @assert length(v) == tree.nf
    x, y = get_element_corner_coordinates(tree, e_id)
    d = get_element_size(tree, e_id)
    @assert (x <= xp <= x + d) && (y <= yp <= y + d)
    eta = (xp - x)/d
    f_id_left = tree.e2f[LEFT, e_id]
    f_id_right = tree.e2f[RIGHT, e_id]
    vx = (1.0 - eta) * v[f_id_left] + eta * v[f_id_right]

    xi = (yp - y)/d
    f_id_down = tree.e2f[DOWN, e_id]
    f_id_up = tree.e2f[UP, e_id]
    vy = (1.0 - xi) * v[f_id_down] + xi * v[f_id_up]

    return vx, vy
end;
