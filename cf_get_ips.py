import requests

# Cloudflare 官方 IP 地址列表 URL
CF_URLS = [
    "https://www.cloudflare.com/ips-v4",
    "https://www.cloudflare.com/ips-v6"
]

def fetch_cloudflare_ips():
    ips = []
    for url in CF_URLS:
        try:
            response = requests.get(url, timeout=10)
            response.raise_for_status()  # 检查 HTTP 请求是否成功
            ips.extend(response.text.strip().split("\n"))
        except requests.RequestException as e:
            print(f"获取 {url} 失败: {e}")
    return ips

def save_to_file(ips, filename="cf_ips.txt"):
    with open(filename, "w") as f:
        for ip in ips:
            f.write(ip + "\n")
    print(f"Cloudflare IPs 已保存到 {filename}")

if __name__ == "__main__":
    cf_ips = fetch_cloudflare_ips()
    if cf_ips:
        save_to_file(cf_ips)
    else:
        print("未能获取 Cloudflare IP 地址，请检查网络连接。")
