import yt_dlp
import json

def fetch_metadata(url):
    """
    Fetches video metadata using yt-dlp.
    Returns a JSON string with title, thumbnail, formats.
    """
    ydl_opts = {
        'quiet': True,
        'no_warnings': True,
        'extract_flat': False,
        'skip_download': True,
    }
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            
            formats = []
            for f in info.get('formats', []):
                fmt = {
                    'format_id': f.get('format_id', ''),
                    'ext':       f.get('ext', 'mp4'),
                    'width':     f.get('width'),
                    'height':    f.get('height'),
                    'note':      f.get('format_note', ''),
                    'filesize':  f.get('filesize') or f.get('filesize_approx'),
                    'url':       f.get('url'),
                    'vcodec':    f.get('vcodec', 'none'),
                    'acodec':    f.get('acodec', 'none'),
                    'abr':       f.get('abr'),
                    'tbr':       f.get('tbr'),
                }
                formats.append(fmt)
            
            result = {
                'title':     info.get('title', 'Unknown'),
                'thumbnail': info.get('thumbnail'),
                'duration':  info.get('duration'),
                'uploader':  info.get('uploader'),
                'formats':   formats,
            }
            return json.dumps(result)
    except Exception as e:
        return json.dumps({'error': str(e)})
