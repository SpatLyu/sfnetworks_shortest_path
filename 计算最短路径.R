library(sf)
library(tidygraph)
library(tidyverse)
library(sfnetworks)

plan = read_sf('./data/Plan.shp') |> 
  st_transform(32651)
road = read_sf('./data/Road.shp') |> 
  st_transform(32651)

net = road %>% 
  as_sfnetwork(directed = FALSE) %>%
  activate("edges") %>%
  mutate(weight = edge_length())

paths = st_network_paths(net,
                         from = plan[1,],
                         to = plan[2,],
                         weights = "weight")
paths

st_nearest_feature(plan[1,], net)
st_nearest_feature(plan[2,], net)
st_nearest_feature(plan[3,], net)

plot(st_geometry(road),col='grey',lwd=1)
plot(st_geometry(plan),col='red',cex=.5,add=T)
plot(st_geometry(road[24,]),col='blue',lwd=.8,add=T)
plot(st_geometry(road[22,]),col='blue',lwd=.8,add=T)
plot(st_geometry(road[1,]),col='blue',lwd=.8,add=T)
plot(st_geometry(road[18,]),col='blue',lwd=.8,add=T)
plot(st_geometry(road[19,]),col='blue',lwd=.8,add=T)

road = read_sf('./data/Road.shp') |> 
  st_transform(32651) |> 
  st_union() |> 
  st_cast('LINESTRING') %>% 
  st_sf(geometry=.)
  
write_sf(road,'./data/school.gdb',layer='road')
write_sf(plan,'./data/school.gdb',layer='plan')  

road = read_sf('./data/school.gdb',layer='road_split') |> 
  st_geometry() |> 
  st_cast('LINESTRING') %>% 
  st_sf(geometry=.)

net = road %>% 
  as_sfnetwork(directed = FALSE) %>%
  activate("edges") %>%
  mutate(weight = edge_length())

path_12 = st_network_paths(net,
                         from = plan[1,],
                         to = plan[2,],
                         weights = "weight")
path_12

net |> 
  activate('edges') |> 
  st_as_sf() -> road_edge

path_12 |> 
  pull(edge_paths) |> 
  unlist() -> plan_12

plot(st_geometry(road),col='grey')
plot(st_geometry(plan[1:2,]),col='red',cex=.5,add=T)
plot(st_geometry(road_edge[plan_12,]),lwd=.2,col='blue',add=T)

path_23 = st_network_paths(net,
                           from = plan[2,],
                           to = plan[3,],
                           weights = "weight")

path_23 %>%
  pull(edge_paths) %>%
  unlist() -> plan_23

plot(st_geometry(road),col='grey')
plot(st_geometry(plan[2:3,]),col='red',cex=.5,add=T)
plot(st_geometry(road_edge[plan_23,]),lwd=.2,col='blue',add=T)

road_edge[plan_12,] |> 
  st_geometry() |> 
  st_union(road_edge[plan_23,] |> st_geometry()) |> 
  st_cast('LINESTRING') -> plan_road

plot(st_geometry(road),col='grey')
plot(st_geometry(plan),col='red',cex=.5,add=T)
plot(st_geometry(plan_road),lwd=.2,col='blue',add=T)

road_edge[plan_12,] |> 
  st_geometry() |> 
  write_sf('./data/school.gdb',layer='校门口到报到点最短路径')
road_edge[plan_23,] |> 
  st_geometry() |> 
  write_sf('./data/school.gdb',layer='报到点到宿舍最短路径')
plan_road |> 
  write_sf('./data/school.gdb',layer='新生报到最短路径')