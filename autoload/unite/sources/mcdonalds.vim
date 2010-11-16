let s:save_cpo = &cpo
set cpo&vim

let s:source_hamburger = { 'name': 'hamburger' }
let s:source_drink = { 'name': 'drink' }
let s:hamburger = []
let s:drink = []

function! unite#sources#mcdonalds#open_url(url)
  if has('win32')
    exe "!start rundll32 url.dll,FileProtocolHandler " . a:url
  elseif has('mac')
    call system("open '" . a:url . "' &")
  elseif executable('xdg-open')
    call system("xdg-open '" . a:url  . "' &")
  else
    call system("firefox '" . a:url . "' &")
  endif
endfunction

function! s:get_menu()
  let res = http#get("http://www.mcdonalds.co.jp/menu/regular/index.html")
  let dom = html#parse(iconv(res.content, 'utf-8', &encoding))
  for li in dom.find('ul', {'class': 'food-set'}).childNodes('li')
    let url = 'http://www.mcdonalds.co.jp' . li.childNode('a').attr['href']
    let name = li.find('img').attr['alt']
    call add(s:hamburger, [name, url])
  endfor
  for li in dom.find('ul', {'class': 'drink-set'}).childNodes('li')
    let url = 'http://www.mcdonalds.co.jp' . li.find('a').attr['href']
    let name = li.find('img').attr['alt']
    call add(s:drink, [name, url])
  endfor
endfunction

function! s:source_hamburger.gather_candidates(args, context)
  if empty(s:hamburger) && empty(s:drink) | call s:get_menu() | endif
  return map(copy(s:hamburger), '{
        \ "word": v:val[0],
        \ "source": "hamburger",
        \ "kind": "command",
        \ "action__command": "call unite#sources#mcdonalds#open_url(''".v:val[1]."'')"
        \ }')
endfunction

function! s:source_drink.gather_candidates(args, context)
  if empty(s:hamburger) && empty(s:drink) | call s:get_menu() | endif
  return map(copy(s:drink), '{
        \ "word": v:val[0],
        \ "source": "drink",
        \ "kind": "command",
        \ "action__command": "call unite#sources#mcdonalds#open_url(''".v:val[1]."'')"
        \ }')
endfunction

function! unite#sources#mcdonalds#define()
  return executable('curl') ? [s:source_hamburger, s:source_drink] : []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
