[.[] | select(.type == "user" and (.message.content | type) == "string")] | length
