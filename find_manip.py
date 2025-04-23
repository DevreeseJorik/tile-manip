import os
import json

base_path = os.path.dirname(os.path.abspath(__file__))
searched_tiles_dir = os.path.join(base_path, "searched_tiles_converted")
chunk_data_path = os.path.join(base_path, "data", "chunk_data.json")

def find_tile(tile_ids, chunk_ids=None, walkable=None):
    for i, tile_id in enumerate(tile_ids):
        if isinstance(tile_id, str):
            tile_ids[i] = int(tile_id, 16) if tile_id.startswith("0x") else int(tile_id)

    results = []
    results = []
    for filename in os.listdir(searched_tiles_dir):
        if not filename.endswith(".json"):
            continue

        with open(os.path.join(searched_tiles_dir, filename), "r") as f:
            tile_data = json.load(f)

        primary_map_ids = tile_data["primary_map_ids"]
        for result in tile_data["results"]:
            secondary_map_ids = result["map_ids"]
            for chunk_name, chunk_data in result["tile_data"].items():
                chunk_id = int(chunk_name[-1])
                if chunk_ids and chunk_id not in chunk_ids:
                    continue

                offset = chunk_data["offset"]
                tiles = chunk_data["tiles"]
                for i, tile_data in enumerate(tiles):
                    if walkable and tile_data["walkable"] != walkable:
                        continue

                    tile_id = tile_data["tile"]
                    if tile_id in tile_ids:
                        results.append({
                            "primary_map_ids": primary_map_ids,
                            "secondary_map_ids": secondary_map_ids,
                            "chunk": chunk_id,
                            "offset": offset,
                            "tile_data": tile_data,
                            "tile_position": i
                        })

    return results

tile_ids = [0xA7]
chunk_ids = [1,2,3,4]
walkable = None

hex_mode = False
def hex_or_int(value):
    """Returns the value as a hex string if hex_mode is True, otherwise as an int."""
    if isinstance(value, list) or isinstance(value, tuple):
        return [hex_or_int(v) for v in value]
    return hex(value).upper().replace("0X", "0x") if hex_mode else value

matches = find_tile(tile_ids, chunk_ids, walkable)
matches.sort(key=lambda match: match["tile_data"]["tile"])

grouped_matches = {}
for match in matches:
    tile_id = match["tile_data"]["tile"]
    if tile_id not in grouped_matches:
        grouped_matches[tile_id] = []
    grouped_matches[tile_id].append(match)

for tile_id, tile_matches in grouped_matches.items():
    result = f"Results for Tile ID: {hex_or_int(tile_id)}\n"
    result += "=" * 40 + "\n"
    for match in tile_matches:
        result += f"Primary Map IDs: {hex_or_int(match['primary_map_ids'])}\n"
        result += f"Secondary Map IDs: {hex_or_int(match['secondary_map_ids'])}\n"
        result += f"Chunk: {hex_or_int(match['chunk'])}, Tile Position: {hex_or_int(match['tile_position'])}\n"
        result += "-" * 40 + "\n"

with open("results.txt", "w") as f:
    f.write(result)