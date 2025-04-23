import os
import json

# Base path (relative to the script's location)
base_path = os.path.dirname(os.path.abspath(__file__))
searched_tiles_dir = os.path.join(base_path, "searched_tiles")
chunk_data_path = os.path.join(base_path, "data", "chunk_data.json")
converted_tiles_dir = os.path.join(base_path, "searched_tiles_converted")

# Ensure the output directory exists
os.makedirs(converted_tiles_dir, exist_ok=True)

# Load chunk_data.json
with open(chunk_data_path, "r") as chunk_file:
    chunk_data = json.load(chunk_file)

# Process all JSON files in the searched_tiles directory
for filename in os.listdir(searched_tiles_dir):
    if filename.endswith(".json"):
        file_path = os.path.join(searched_tiles_dir, filename)

        # Load the searched_tiles JSON file
        with open(file_path, "r") as tile_file:
            tile_data = json.load(tile_file)

        # Reorder and restructure tile_data
        for result in tile_data["results"]:
            reordered_tile_data = {}
            for map_id, offsets in enumerate(chunk_data):
                for index, offset in enumerate(offsets["chunk_offsets"]):
                    if offset in result["tile_data"]:
                        reordered_tile_data[f"chunk_{index + 1}"] = {
                            "offset": offset,
                            "tiles": result["tile_data"][offset]
                        }
            result["tile_data"] = reordered_tile_data

        # Save the modified file back to the converted directory
        converted_file_path = os.path.join(converted_tiles_dir, filename)
        with open(converted_file_path, "w") as tile_file:
            json.dump(tile_data, tile_file, indent=4)

print("Tile data restructuring complete.")