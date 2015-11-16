import arcpy

def getState(x,y):
    inPt = arcpy.Point(x,y)
    shp = r"<your_path_to_data>\USA.gdb\states"
    fields = ["SHAPE@", "NAME"]
    stateWithin = ""
    with arcpy.da.SearchCursor(shp, fields) as cursor:
        for row in cursor:
            if inPt.within(row[0]):
                stateWithin = row[1]
                break
    return stateWithin
