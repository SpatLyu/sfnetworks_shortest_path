import os
import arcpy
arcpy.env.overwriteOutput = True
arcpy.SplitLine_management('./data/school.gdb/road','./data/school.gdb/road_split')
