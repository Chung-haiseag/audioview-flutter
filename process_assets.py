from PIL import Image
import os

# Paths
# source_path should be updated to a relative path or provided as an argument
source_path = os.path.join(os.getcwd(), "original_asset.jpg") 
output_dir = "assets/images"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Open image
img = Image.open(source_path)
width, height = img.size
mid_x = width // 2
mid_y = height // 2

# Define quadrants
# Top Left: App Icon
icon_img = img.crop((0, 0, mid_x, mid_y))
# Top Right: Splash Logo
splash_img = img.crop((mid_x, 0, width, mid_y))
# Bottom Left: Horizontal Logo
logo_img = img.crop((0, mid_y, mid_x, height))
# Bottom Right: Placeholder Poster
poster_img = img.crop((mid_x, mid_y, width, height))

# Save assets
icon_img.save(os.path.join(output_dir, "app_icon.png"))
splash_img.save(os.path.join(output_dir, "splash_logo.png"))
logo_img.save(os.path.join(output_dir, "logo_horizontal.png"))
poster_img.save(os.path.join(output_dir, "placeholder_poster.png"))

print("Assets processed and saved to " + output_dir)
