-- tamacat by viztini

cat_normal = {
 " /\\_/\\ ",
 "( o.o )",
 " > ^ < "
}

cat_happy = {
 " /\\_/\\ ",
 "( o.o )",
 " > v < "
}

cat_tired = {
 " /\\_/\\ ",
 "( -.- )",
 " > ^ < "
}

cat_blink = {
 " /\\_/\\ ",
 "( ^.^ )",
 " > ^ < "
}

cat_sad = {
 " /\\_/\\ ",
 "( x.x )",
 " > ^ < "
}

cat_states = {
 normal=cat_normal,
 happy=cat_happy,
 tired=cat_tired,
 blink=cat_blink,
 sad=cat_sad
}

state="normal"
next_state="normal"
blink_timer=0
blink_rate=120
blink_duration=8

-- sleep mechanics
is_napping = false
sleep_timer = 0
nap_duration = 0

-- action duration
action_duration = 0

-- stats (full bar = good)
nutrition = 50
happiness = 50
tiredness = 50
mood = 50

function _update()
 -- stat decay
 if not is_napping then
  nutrition -= 0.02
  happiness -= 0.015
  tiredness += 0.02
  
  -- mood decay
  if time() % 150 == 0 then
   if nutrition < 50 or happiness < 50 then
    mood -= 1
   else
    mood -= 0.2
   end
  end
 else
  -- reduces tired during nap
  tiredness -= 0.45
 end

 -- clamp stats
 nutrition = mid(0, nutrition, 100)
 happiness = mid(0, happiness, 100)
 tiredness = mid(0, tiredness, 100)
 mood = mid(0, mood, 100)

 -- nap/sleep logic
 if is_napping then
  sleep_timer += 1
  if sleep_timer >= nap_duration or tiredness == 0 then
   is_napping = false
   sleep_timer = 0
   next_state = "normal"
  end
  state = "tired"
  return
 end

 -- nap trigger
 if tiredness > 60 and nutrition > 20 and happiness > 20 and not is_napping then
  if rnd(20) < 1 then
   nap_duration = rnd(3600) + 5400
  else
   nap_duration = rnd(450) + 900
  end
  is_napping = true
 end

 -- action state logic
 local action_trigger = false

 if btnp(4) then -- z: feed
  nutrition += 25
  mood += 15
  nutrition = min(nutrition, 100)
  mood = min(mood, 100)
  state = "happy"
  action_trigger = true
 end

 if btnp(5) then -- x: play
  happiness += 15
  tiredness += 15
  mood += 15
  happiness = min(happiness, 100)
  tiredness = min(tiredness, 100)
  mood = min(mood, 100)
  state = "happy"
  action_trigger = true
 end

 -- set action duration
 if action_trigger then
  action_duration = rnd(60) + 90
  next_state = "normal"
  return
 end

 -- blink logic
 blink_timer += 1
 if state == "blink" then
  if blink_timer > blink_duration then
   state = next_state
   blink_timer = 0
  end
 else
  if blink_timer > blink_rate then
   blink_timer = 0
   next_state = state
   state = "blink"
  end
 end

 -- passive state logic
 if state ~= "blink" and state ~= "happy" and not is_napping then
  if tiredness > 70 then
   state = "tired"
  elseif nutrition < 50 and happiness < 50 and mood < 50 then
   state = "sad"
  elseif happiness > 75 then
   state = "happy"
  elseif mood < 25 or nutrition < 25 or happiness < 25 then
   state = "normal"
  else
   state = "normal"
  end
  next_state = state
 end

 -- handle transition from temporary 'happy' state
 if state == "happy" and not action_trigger then
  action_duration -= 1
  if action_duration <= 0 then
   state = next_state
   action_duration = 0
  end
 end
end

function bar(x,y,val,col)
 local max_inner_width = 28
 local fill_width = val * max_inner_width / 100
 rect(x, y, x+30, y+5, 1)
 rectfill(x+1, y+1, x+1+fill_width, y+4, col)
end

function draw_cat()
 local c = cat_states[state]

 if state == "blink" then
  local base_c = cat_states[next_state]
  print(base_c[1], 48, 30+(1*8), 7)
  print(cat_blink[2], 48, 30+(2*8), 7)
  print(base_c[3], 48, 30+(3*8), 7)
 else
  for i=1,#c do
   print(c[i], 48, 30+(i*8), 7)
  end
 end
end

function _draw()
 cls(0)
 print("🐱 tamacat", 45, 4, 7)

 draw_cat()

 -- stats bars
 print("mood", 132, 74, 10)
 bar(132, 82, mood, 10)

 print("nutrition", 6, 74, 11)
 bar(6, 82, nutrition, 8)

 print("happiness", 48, 74, 12)
 bar(48, 82, happiness, 10)

 print("tiredness", 90, 74, 9)
 bar(90, 82, tiredness, 2)

 -- controls
 print("z: feed   x: play", 22, 104, 7)
end
