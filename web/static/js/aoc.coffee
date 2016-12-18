#!/usr/bin/env coffee

output = console.log
debug = console.log
ARGV = day: process.argv[2]

main = ->
  day = if ARGV.day then Days[ARGV.day] else "wat"
  throw "#{ARGV.day} not implemented" unless day
  day and do ->
    input = ""
    process.stdin.on 'readable', ->
      chunk = process.stdin.read()
      chunk && input = input + chunk
    process.stdin.on 'end', ->
      day(input)

Util =
  invalid_triangle: (a,b,c) -> (+a)+(+b) <= (+c) or (+a)+(+c) <= (+b) or (+b)+(+c) <= (+a)
  md5: require 'md5'

Days =
  day1: (input) ->
    directions = ['n', 'e', 's', 'w']
    d = 'n'
    turngrid =
      nL: 'w'
      nR: 'e'
      eL: 'n'
      eR: 's'
      sL: 'e'
      sR: 'w'
      wL: 's'
      wR: 'n'
    x = y = 0

    input.split(', ').map (item) ->
      turndir = item[0]
      steps = item.slice(1)
      d = turngrid["#{d}#{turndir}"]
      switch d
        when 'n' then y += +steps
        when 's' then y -= +steps
        when 'e' then x += +steps
        when 'w' then x -= +steps
      debug "#{item}: #{x}, #{y} = #{Math.abs(x)+Math.abs(y)}"

    output "#{x}, #{y} = #{Math.abs(x)+Math.abs(y)}"

  day2: (input) ->
    grid = [
      [1,2,3],
      [4,5,6],
      [7,8,9],
    ]

    y = 1
    x = 1

    input.split('\n').map (line) ->
      line.split('').map (d) ->
        switch d
          when 'L' then x = Math.max 0, Math.min 2, x-1
          when 'R' then x = Math.max 0, Math.min 2, x+1
          when 'U' then y = Math.max 0, Math.min 2, y-1
          when 'D' then y = Math.max 0, Math.min 2, y+1
      output grid[y][x]

  day3: (input) ->
    reducer = (accum, cur) ->
      if cur is "" then return accum
      [a,b,c] = cur.trim().split /\s+/
      if Util.invalid_triangle(a, b, c) then accum else accum+1

    console.log input.trim().split('\n').reduce reducer, 0

  day3part2: (input) ->
    lines = input.split '\n'
    idx = 0
    count = 0
    while idx < lines.length-2
      [a,b,c] = lines[idx].trim().split /\s+/
      [h,j,k] = lines[idx+1].trim().split /\s+/
      [x,y,z] = lines[idx+2].trim().split /\s+/
      ++count unless Util.invalid_triangle(a, h, x)
      ++count unless Util.invalid_triangle(b, j, y)
      ++count unless Util.invalid_triangle(c, k, z)
      idx += 3
    console.log count

  day4: (input) ->
    total = 0
    input.trim().split('\n').map (line) ->
      seen = {}
      result = line.match /([-\w]+)-(\d\d\d)\[(\w\w\w\w\w)\]/
      [unused, str, id, hash] = result
      str.split('').map (ch) ->
        return if ch is '-'
        if seen[ch] then ++seen[ch] else seen[ch] = 1

      counts = []
      for k, v of seen
        if !counts[v] then counts[v] = ''
        counts[v] += k

      debug "Seen: #{JSON.stringify seen}"
      debug "Counts: #{JSON.stringify counts}"

      result = ''
      until result.length >= 5 or counts.length == 0
        el = ''
        el = counts.pop() until el
        result += el.split('').sort().join('')
      debug result.slice(0,5)

      if hash == result.slice(0,5)
        console.log "ID: #{id}"
        total += +id

    output total

  day4part2: (input) ->
    total = 0
    input.trim().split('\n').map (line) ->
      seen = {}
      result = line.match /([-\w]+)-(\d\d\d)\[(\w\w\w\w\w)\]/
      [unused, str, id, hash] = result
      str.split('').map (ch) ->
        return if ch is '-'
        if seen[ch] then ++seen[ch] else seen[ch] = 1

      counts = []
      for k, v of seen
        if !counts[v] then counts[v] = ''
        counts[v] += k

      debug "Seen: #{JSON.stringify seen}"
      debug "Counts: #{JSON.stringify counts}"

      result = ''
      until result.length >= 5 or counts.length == 0
        el = ''
        el = counts.pop() until el
        result += el.split('').sort().join('')
      debug result.slice(0,5)

      shift = id % 26
      if hash == result.slice(0,5)
        cipher = (c) ->
          if c is '-' then return ' '
          String.fromCharCode (c.charCodeAt(0) - 97 + shift) % 26 + 97
        output "[#{id}] #{str} = #{str.split('').map(cipher).join ''}"

  day5: (input) ->
    md5 = require 'js-md5'
    i = 0
    found = 0
    input = input.trim()
    while found < 8
      hash = md5.create()
      hash.update "#{input}#{i}"
      hex = hash.hex()
      if hex[0..4] is '00000'
        output "\n\nFrom #{hex}: #{hex[5]}"
        found++
      i++
      if i % 1000 == 0 then process.stdout.write "\r#{i}...(#{hex}): #{hex[0..4]}"

  dayfourteen: ->
    input = 'ngcjuoqr'
    iteration = 0
    keys = []
    index = 0
    found = 0
    ondeck = {}
    while found < 64
      str = Util.md5 "#{input}#{index}"
      result = str.match /000|111|222|333|444|555|666|777|888|999|aaa|bbb|ccc|ddd|eee|fff/
      if result
        [unused, char] = result
        if char
          # debug "Char was #{char} from #{str}"
          char = char[0]
          ondeck[index] = [str, char]

      result = str.match /00000|11111|22222|33333|44444|55555|66666|77777|88888|99999|aaaaa|bbbbb|ccccc|ddddd|eeeee|fffff/
      if result
        [unused, char] = result
        if char
          char = char[0]
          process.stdout.write "\rchecking #{str}"
          for previndex in [index-1000..index-1]
            if ondeck[previndex] 
              [prevstr, prevchar] = ondeck[previndex] 
              if prevchar == char
                output "\nIndex #{previndex} gave #{prevstr} matched by #{str} at #{index}"
                found++
      ++index

main()

module.exports = Days
