#Backtracking Sequential Coloring algorithm
include("custom_graph.jl")

function bsc_color(G::CGraph)
    V = num_vertices(G)
    F = zeros(Int64, V)
    freeColors = [Vector{Int64}() for _ in 1:V] #set of free colors for each vertex
    U = zeros(Int64, 0) #stores set of free colors
    #F = zeros(Int64, 0) #stores final coloring of vertices

    sorted_vertices = order_by_degree(G)
    start = 1
    optColorNumber = V + 1
    x = sorted_vertices[1]
    colors[0] = 0
    push!(U, 1)
    freeColors[x] = U

    while (start >= 1)
        back = false
        for i = 1:V
            if i > start
                x = find_uncolored_vertex(sorted_vertices, F)
                U = free_colors(x,F,G,optColorNumber)
                sort(U)
            end
            if length(U) > 0
                k = U[1]
                F[x] = k
                deleteat!(U,1)
                freeColors[x] = copy(U)
                l = colors[i-1]
                colors[i] = max(k,l)
            else
                start = i - 1
                back = true
                break
            end
        end
        if back
            if start >= 1
                x = A[start]
                F[x] = 0 #uncolor x
                U = freeColors[x]
            end
        else
            F_opt = F
            optColorNumber = colors[V-1]
            i = least_index(sorted_vertices,optColorNumber,G)
            start = i - 1
            if start < 1
                break #leave the while loop
            end
            uncolor_all(F, sorted_vertices, start, G)
            for i = 0:start
                x  = A[i]
                U = freeColors[x]
                U = remove_colors(U, optColorNumber)
                freeColors[x] = copy(U)
            end
        end
    end
    return F_opt
end


"""
    vertex_degree(G,z)

Find the degree of the vertex z which belongs to the graph G.
"""
function degree(G::CGraph,z::Int64)
    return length(neighbors(G,z))
end


function sorted_vertices(G::CGraph)
    V = length(vertices(G))
    marked = zeros(Int64,V)
    sv = zeros(Int64,0)
    max_degree = -1
    max_degree_vertex = -1
    for i = 1:V
        max_degree = -1
        max_degree_vertex = -1
        for j = 1:V
            if j != i
                if degree(G,j) > max_degree && marked[j] == 0
                    max_degree = degree(G,j)
                    max_degree_vertex = j
                end
            end
        end
        push!(sv,max_degree_vertex)
        marked[max_degree_vertex] = 1
    end
    return sv
end

#find uncolored vertex of maximal degree of saturation
function find_uncolored_vertex(sv::Array{Int64,1}, G::CGraph)
    colors = zeros(Int64,0)
    max_colors = -1
    max_color_index = -1
    for i = 1:length(vertices(G))
        if F[i] != 0
            for j in neighbors(G,i)
                if F[j] != 0 && F[j] in colors == false
                    push!(colors, F[j])
                end
            end
            if length(colors) > max_colors
                max_colors = length(colors)
                max_color_index = i
            end
        end
        colors = zeros(Int64,0)
    end
    for i = 1:length(vertices(G))
        if A[i] == max_color_index
            return i
        end
    end

end

#set of free colors of x, which are < optColorNumber
function free_colors(x::Int64, F::Array{Int64,1}, G::CGraph, max_color::Int64)
    colors = zeros(Int64,0)
    for color in 1:max_color
        present = true
        for y in neighbors(G,x)
            if F[y] == color
                present = false
                break
            end
        end
        if present
            push!(colors,color)
        end
    end
    return colors
end

#least index with F(A[i]) = optColorNumber
function least_index(A::Array{Int64, 1}, F::Array{Int64,1}, optColorNumber::Int64, G::CGraph)
    for i = 1:length(G.vertices)
        if F[A[i]] == optColorNumber
            return i
        end
    end
end

#uncolor all vertices A[i] with i >= start
function uncolor_all(F::Array{Int64,1}, A::Array{Int64,1}, start::Int64, G::CGraph)
    for i = start:length(G.vertices)
        F[A[i]] = 0
    end
end

#remove from U all colors >= optColorNumber
function remove_colors(U::Array{Int64,1}, optColorNumber::Int64)
    modified_U = zeros(Int64,0)
    for i = 1:length(U)
        if U[i] < optColorNumber
            push!(mmodified_U, U[i])
        end
    end
    return modified_U
end
