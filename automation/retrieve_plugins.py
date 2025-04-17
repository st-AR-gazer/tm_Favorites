import requests
import re
import time
import os

def scrape_openplanet_identifiers(start_id=1, end_id=900, output_file='plugins.txt'):
    pattern = re.compile(r'filename="([^"]+)\.op"')
    
    headers = {
        "User-Agent": "ar here, downloading all the op plugins so that I can generate a proper 'favorites' file :Okayge:"
    }
    
    with open(output_file, 'w', encoding='utf-8', buffering=1) as f:
        for plugin_id in range(start_id, end_id + 1):
            url = f"https://openplanet.dev/plugin/{plugin_id}/download"
            try:
                r = requests.get(url, headers=headers, allow_redirects=True, stream=True)
                
                if r.status_code == 200:
                    cd_header = r.headers.get("Content-Disposition")
                    if cd_header:
                        match = pattern.search(cd_header)
                        if match:
                            identifier = match.group(1)
                            print(f"Found plugin #{plugin_id}: {identifier}")
                            f.write(identifier + "\n")
                        else:
                            print(f"Plugin #{plugin_id} - Couldn't parse name from Content-Disposition.")
                    else:
                        final_url = r.url
                        fallback_filename = os.path.basename(final_url).split('?')[0]
                        
                        if fallback_filename.lower().endswith('.op'):
                            identifier = fallback_filename[:-3]
                        else:
                            identifier = fallback_filename
                        
                        if identifier:
                            print(f"Found plugin #{plugin_id} (fallback): {identifier}")
                            f.write(identifier + "\n")
                        else:
                            print(f"Plugin #{plugin_id} - Unable to determine filename from the URL.")
                else:
                    print(f"Plugin #{plugin_id} - Invalid status code: {r.status_code}")
            except requests.RequestException as e:
                print(f"Plugin #{plugin_id} - Request failed: {e}")
            finally:
                r.close()
            
            time.sleep(1)

if __name__ == "__main__":
    scrape_openplanet_identifiers()
