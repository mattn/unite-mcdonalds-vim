let s:save_cpo = &cpo
set cpo&vim

let s:source_hamburger = {
\ 'name': 'mcdonalds.hamburger',
\ 'description': 'ハンバーガー',
\}
let s:source_drink = {
\ 'name': 'mcdonalds.drink',
\ 'description': 'ドリンク',
\}
let s:hamburger = []
let s:drink = []

function! unite#sources#mcdonalds#define()
  return executable('curl') ? [s:source_hamburger, s:source_drink] : []
endfunction


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

function! s:source_hamburger.gather_candidates(args, context)
  if empty(s:hamburger)
    let res = webapi#http#get('http://www.mcdonalds.co.jp/menu/regular/index.html')
    let dom = webapi#html#parse(iconv(res.content, 'utf-8', &encoding))
    for col in dom.findAll('div', {'class': 'column'})
      let url = 'http://www.mcdonalds.co.jp' . col.childNode('a').attr['href']
      let imgs = col.findAll('img')
      if len(imgs) == 2
        call add(s:hamburger, [imgs[1].attr["alt"], url])
      endif
    endfor
  endif
  return map(copy(s:hamburger), '{
        \ "word": v:val[0],
        \ "source": "hamburger",
        \ "kind": "command",
        \ "action__command": "call unite#sources#mcdonalds#open_url(''".v:val[1]."'')"
        \ }')
endfunction

function! s:source_drink.gather_candidates(args, context)
  if empty(s:drink)
    let res = webapi#http#get('http://www.mcdonalds.co.jp/menu/regular/drink.html')
    let dom = webapi#html#parse(iconv(res.content, 'utf-8', &encoding))
    for li in dom.find('ul', {'class': 'dring_list'}).childNodes("li")
      let url = 'http://www.mcdonalds.co.jp' . li.find('a').attr['href']
      call add(s:drink, [li.find('img').attr["alt"], url])
    endfor
  endif
  return map(copy(s:drink), '{
        \ "word": v:val[0],
        \ "source": "drink",
        \ "kind": "command",
        \ "action__command": "call unite#sources#mcdonalds#open_url(''".v:val[1]."'')"
        \ }')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
