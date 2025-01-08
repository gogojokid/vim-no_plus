vim9script

import autoload '../autoload/nocomment.vim'

def g:NcToggleRight()
    nocomment.ToggleCommentRight()
enddef

def g:NcToggleLeft()
    nocomment.ToggleCommentLeft()
enddef

command! -nargs=0 -range NcToggleDownV nocomment.ToggleCommentDownV()
command! -nargs=0 -range NcToggleUpV nocomment.ToggleCommentUpV()
command! -nargs=0 -range NcToggleRightV nocomment.ToggleCommentRightV()
command! -nargs=0 -range NcToggleLeftV nocomment.ToggleCommentLeftV()
