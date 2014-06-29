# Tick formatter identity.
Epoch.Formats.regular = (d) -> d

# Tick formatter that formats the numbers using standard SI postfixes.
Epoch.Formats.si = (d) -> Epoch.Util.formatSI(d)

# Tick formatter for percentages.
Epoch.Formats.percent = (d) -> (d*100).toFixed(1) + "%"

# Tick formatter for seconds from timestamp data.
Epoch.Formats.seconds = (t) -> d3Seconds(new Date(t*1000))
d3Seconds = d3.time.format('%I:%M:%S %p')

# Tick formatter for bytes
Epoch.Formats.bytes = (d) -> Epoch.Util.formatBytes(d)
