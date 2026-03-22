class_name CatData
extends Resource
## Data resource for a single hidden cat.
##
## Holds the cat's sprite texture and a text hint describing where it is hiding.
## Used by HiddenObject in the game scene and by the picture book UI.

@export var sprite: Texture2D
@export_multiline var hint: String = ""
