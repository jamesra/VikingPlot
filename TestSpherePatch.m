up = SpherePatch(8, 10, [0 0 1], true, false)
down = SpherePatch(8, 10, [0 0 -1], true, false)

CreateRenderingFigure()

DrawVertStructure(up, [0 0 0], [1 0 0])

CreateRenderingFigure()

DrawVertStructure(down, [0 0 0], [0 0 1])

