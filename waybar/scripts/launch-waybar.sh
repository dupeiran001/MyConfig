#!/bin/bash
# Generate dynamic waybar config based on hardware, then launch waybar
CONFIG_DIR="/home/dpr/.config/waybar"
GENERATED_JSON="$CONFIG_DIR/generated.jsonc"
GENERATED_CSS="$CONFIG_DIR/generated.css"

if grep -q "appledrm.show_notch=1" /proc/cmdline 2>/dev/null; then
    BAR_HEIGHT=38
else
    BAR_HEIGHT=24
fi

cat > "$GENERATED_JSON" <<EOF
{
  "height": ${BAR_HEIGHT}
}
EOF

# Scale arrow font sizes proportionally to bar height (baseline: 24px)
if [ "$BAR_HEIGHT" -ge 38 ]; then
  FONT_PX=13
else
  FONT_PX=11
fi
ARROW_PT=$(echo "scale=1; 14 * $BAR_HEIGHT / 24" | bc)
DISTRO_PT=$(echo "scale=1; 11 * $BAR_HEIGHT / 24" | bc)

cat > "$GENERATED_CSS" <<EOF
/* Auto-generated — sizes scaled for bar height ${BAR_HEIGHT}px */
* {
  font-size: ${FONT_PX}px;
}
#custom-left1,
#custom-left2,
#custom-left3,
#custom-left4,
#custom-left5,
#custom-left6,
#custom-left7,
#custom-left8 {
  font-size: ${ARROW_PT}pt;
}

#custom-right1,
#custom-right2,
#custom-right3,
#custom-right4,
#custom-right5 {
  font-size: ${ARROW_PT}pt;
}

#custom-leftin1,
#custom-leftin2 {
  font-size: ${ARROW_PT}pt;
}

#custom-rightin1 {
  font-size: ${ARROW_PT}pt;
}

#custom-distro.normal {
  font-size: ${DISTRO_PT}pt;
  margin-bottom: -2px;
}
EOF

exec waybar
