require 'cairo'

conky_start = 1

function conky_main()
  if conky_window == nil then return end
  local cs = cairo_xlib_surface_create(
    conky_window.display,
    conky_window.drawable,
    conky_window.visual,
    conky_window.width,
    conky_window.height
  )
  cr = cairo_create(cs)


  local updates = tonumber(conky_parse('${updates}'))
  if updates>1 then

  -- Info to terminal --
  --- 'Conky is running' 1/s ---
    --print ("conky is running!")

  -- Parsing --
    cpu     =tonumber(conky_parse("${cpu}"))
    memory  =tonumber(conky_parse("${memperc}"))
    internet_connected = tonumber(conky_parse("${if_up wlan0}1${else}0${endif}"))

  -- Screen --
    screen_x = 1920
    screen_y = 1080
  -- Object --
    --- Circle ---
    ---- Property ----
    center_x_c = 960
    center_y_c = 540
    radius_c = 250
    width_c = 5
    start_angle_c = 0
    end_angle_c = 2*math.pi
    bg_red_c = 1
    bg_green_c = 1
    bg_blue_c = 1
    bg_alpha_c = 0.7
    ---- Draw ----
    cairo_set_line_width (cr, width_c)
    cairo_set_source_rgba (cr, bg_red_c, bg_green_c, bg_blue_c, bg_alpha_c)
    cairo_arc (cr, center_x_c, center_y_c, radius_c, start_angle_c, end_angle_c)
    cairo_close_path (cr)
    cairo_stroke (cr)

    --- Date & Time ---
    local extents=cairo_text_extents_t:create()
    tolua.takeownership(extents)
    ---- Property ----
    dtcenter_font="Noto Sans"
    dtcenter_font_slant = CAIRO_FONT_SLANT_NORMAL
    dtcenter_font_face = CAIRO_FONT_WEIGHT_NORMAL
    dtcenter_font_size=96
    dtcenter_seconds=os.date("%S")
    dtcenter_minutes=os.date("%M")
    dtcenter_hours=os.date("%H")
    dtcenter_text = dtcenter_hours .. ":" .. dtcenter_minutes .. ":" .. dtcenter_seconds
    --dtcenter_time = tonumber(os.date("%X"))
    --dtcenter_text = dtcenter_time .. ":"
    ---- Drawing ----
    cairo_select_font_face (cr, dtcenter_font, dtcenter_font_slant, dtcenter_font_face)
    cairo_set_font_size (cr, dtcenter_font_size)
    cairo_set_source_rgba (cr,1,1,1,0.6)
    cairo_text_extents (cr, dtcenter_text, extents)
    dtcenter_xpos = screen_x/2 - (extents.width/2 + extents.x_bearing)
    dtcenter_ypos = screen_y/2 - (extents.height/2 + extents.y_bearing)
    cairo_move_to (cr, dtcenter_xpos, dtcenter_ypos)
    cairo_show_text (cr, dtcenter_text)
    cairo_stroke(cr)
    --- System Log ---
    cairo_select_font_face (cr, sl_font, sl_font_slant, sl_font_face)
    cairo_set_font_size (cr, sl_font_size)
    cairo_set_source_rgba(cr,1,1,1,0.7)
    sl_interval = 5
    sl_timer = (updates % sl_interval)
    ---- Property ----
    sl_font="Inconsolata"
    sl_font_slant = CAIRO_FONT_SLANT_NORMAL
    sl_font_face = CAIRO_FONT_WEIGHT_NORMAL
    sl_font_size = 15
    sl_xpos = 40
    sl_ypos = 700


    if sl_timer == 0 or conky_start == 1 then
      sl_content_table = {}
      sl_file = io.open("/home/zaen/.journal", "r")
      for line in sl_file:lines() do
        sl_content = line
        table.insert(sl_content_table, sl_content)
      end
      sl_file:close()
    end
    n = 1
    for i, line in ipairs (sl_content_table) do
      sl_content = line
      sl_ypos = sl_ypos + sl_font_size*1.3
      cairo_move_to (cr,sl_xpos , sl_ypos)
      cairo_show_text (cr, sl_content)
      n = n+1
    end

    --- System Storage Information ---
    cairo_select_font_face (cr, ss_font, ss_font_slant, ss_font_face)
    cairo_set_font_size (cr, ss_font_size)
    cairo_set_source_rgba(cr,1,1,1,0.7)
    ss_interval = 10
    ss_timer = (updates % ss_interval)
    ---- Property ----
    ss_font="Inconsolata"
    ss_font_slant = CAIRO_FONT_SLANT_NORMAL
    ss_font_face = CAIRO_FONT_WEIGHT_NORMAL
    ss_font_size = 18
    ss_xpos = 40
    ss_ypos = 400


    if ss_timer == 0 or conky_start == 1 then
    ss_content_table = {}
      ss_file = io.popen("df -h")
      for line in ss_file:lines() do
        ss_content = line
        table.insert(ss_content_table, ss_content)
      end
      ss_file:close()
    end
    n = 1
    for i, line in ipairs(ss_content_table) do
      ss_content = line
      ss_ypos = ss_ypos + ss_font_size*1.4
      cairo_move_to (cr,ss_xpos ,ss_ypos)
      cairo_show_text (cr, ss_content)
      n = n + 1
    end
    cairo_stroke (cr)

    conky_start = nil
  end

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr = nil
end

-- Functions --
--- converts color in hexa to decimal ---
function rgb_to_r_g_b(colour, alpha)
  return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end
function magiclines(str)
  local s = tostring(str)
  a = type(s)
  print (a)
  if s:sub(-1)~="\n" then s=s.."\n" end
  return s:gmatch("(.-)\n")
end
