import matplotlib.pyplot as plt

# pass in qobject derived polyline
def plot_chart(polyline):
    geom = polyline.geometry.json
    elevationList = []
    # loop through the vertices and add z-values to list
    paths = geom['paths'][0]
    for part in paths:
        elevationList.append(part[2])
    # plot the list
    plt.plot(elevationList)
    plt.ylabel('Elevation (meters)')
    plt.show()
