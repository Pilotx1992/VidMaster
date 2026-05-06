import email.message

def parse_header(line):
    """Replacement for cgi.parse_header"""
    if not line:
        return '', {}
    m = email.message.Message()
    m['content-type'] = line
    params = {}
    parsed_params = m.get_params()
    if parsed_params:
        for param in parsed_params[1:]:
            params[param[0]] = param[1]
    return m.get_content_type(), params
