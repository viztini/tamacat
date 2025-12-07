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

-- stats
hunger=50
happy=50
tired=0
mood=50

function _update()
 -- stat decay
 if not is_napping then
  hunger-=0.02
  happy-=0.015
  tired+=0.02
  
  -- mood decay
  if time()%150 == 0 then
   if hunger<50 or happy<50 then
    mood-=1
   else
    mood-=0.2
   end
  end
 else
  -- reduces tired during nap
  tired-=0.45 
 end

 -- clamp stats
 hunger=mid(0,hunger,100)
 happy=mid(0,happy,100)
 tired=mid(0,tired,100)
 mood=mid(0,mood,100)

 -- nap/sleep logic
 if is_napping then
  sleep_timer += 1
  -- wake up check
  if sleep_timer >= nap_duration or tired == 0 then
   is_napping = false
   sleep_timer = 0
   next_state = "normal" 
  end
  state = "tired" 
  return 
 end

 -- nap trigger
 if tired > 60 and hunger > 20 and happy > 20 and not is_napping then
  if rnd(20) < 1 then 
   -- long nap
   nap_duration = rnd(3600) + 5400 
  else
   -- short nap
   nap_duration = rnd(450) + 900
  end
  is_napping = true
 end
 
 -- action state logic
 local action_trigger = false
 
 if btnp(4) then -- z: feed
  hunger+=25
  mood+=15 
  hunger=min(hunger,100)
  mood=min(mood,100)
  state="happy" 
  action_trigger = true
 end

 if btnp(5) then -- x: play
  happy+=15
  tired+=15
  mood+=15 
  happy=min(happy,100)
  tired=min(tired,100) 
  mood=min(mood,100)
  state="happy"
  action_trigger = true
 end
 
 -- set action duration
 if action_trigger then
  action_duration = rnd(60) + 90 
  next_state = "normal" 
  return 
 end

 -- blink logic
 blink_timer+=1
 if state=="blink" then
  if blink_timer>blink_duration then
   state=next_state 
   blink_timer=0
  end
 else
  if blink_timer>blink_rate then
   blink_timer=0
   next_state=state 
   state="blink"
  end
 end

 -- passive state logic
 if state~="blink" and state~="happy" and not is_napping then
  
  -- 1. tired state check
  if tired>70 then
   state="tired"
  
  -- 2. sad state check (all important bars < 50)
  elseif hunger<50 and happy<50 and mood<50 then
   state="sad"
  
  -- 3. highly happy state check (only if happiness is > 75)
  elseif happy>75 then
   state="happy"
  
  -- 4. general need/mood check
  elseif mood<25 or hunger<25 or happy<25 then
   state="normal"
   
  -- 5. default idle
  -- are you still here?
  else
   state="normal" 
  end
  next_state = state
 end
 
 -- handle transition from temporary 'happy' state (from button press)
 if state=="happy" and not action_trigger then
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
 
 rect(x,y,x+30,y+5,1) 
 rectfill(x+1,y+1,x+1+fill_width,y+4,col)
end

function draw_cat()
 local c=cat_states[state]
 
 if state=="blink" then
  -- if blinking, use the body and mouth from the state we are returning to
  local base_c = cat_states[next_state]
  
  -- line 1 (head) from base state
  print(base_c[1], 48, 30+(1*8), 7)
  -- line 2 (eyes) from blink sprite
  print(cat_blink[2], 48, 30+(2*8), 7)
  -- line 3 (mouth/feet) from base state
  print(base_c[3], 48, 30+(3*8), 7)
 else
  -- normal drawing for all other states
  for i=1,#c do
   print(c[i], 48, 30+(i*8), 7)
  end
 end
end

-- i know this isnt the best code but its just a quick prototype

function _draw()
 cls(0)

 print(" tamacat",45,4,7)

 draw_cat()
 
 -- mood bar
 print("mood",132,74,10) 
 bar(132,82,mood,10) 

 print("hunger",6,74,11)
 bar(6,82,hunger,8)

 print("happy",48,74,12)
 bar(48,82,happy,10)

 print("tired",90,74,9)
 bar(90,82,tired,2)

 -- controls
 print("z: feed   x: play",22,104,7)
 
end
