program random

 !$ use omp_lib

 integer count
 integer status
 integer argLength
 character(len=10) responder
 character(len=100) arg

 character(len=10) valueType
 character(len=100) seedType
 integer seed
 integer length
 logical concurrent
 logical visible
 logical shown

 valueType="real"
 seedType="time"
 seed=0
 length=1
 concurrent=.false.
 visible=.true.
 shown=.false.

 count = command_argument_count()
 do n=1,count
  call get_command_argument(n,arg,argLength,status)
  if (status==0) then
   if ((count==1).and.((arg=="help").or.(arg=="-help").or.(arg=="--help"))) then
    call help()
    shown=.true.
   else if ((count==1).and.((arg=="version").or.(arg=="-version").or.(arg=="--version"))) then
    call version()
    shown=.true.
   else if ((arg=="-s").or.(arg=="-seed")) then
    responder="seed"
   else if ((arg=="-l").or.(arg=="-length")) then
    responder="length"
   else if ((arg=="-i").or.(arg=="-int")) then
    valueType="int"
   else if ((arg=="-r").or.(arg=="-real")) then
    valueType="real"
   else if ((arg=="-parallel").or.(arg=="-concurrent")) then
    concurrent=.true.
   else if ((arg=="-invisible").or.(arg=="-hidden")) then
    visible=.false.
   else if (responder=="length") then
    read (arg,*) length
    responder=""
   else if (responder=="seed") then
    seedType=arg
    responder=""
   end if
  end if
 end do

 if (.not.shown) then

  if (seedType=="time") then
   seed=time()
  else if (seedType=="none") then
   seed=0
  else
   read (seedType,*) seed
  end if

  call execRand(valueType,seed,visible)

  if (concurrent) then
   !$omp parallel
   !$omp do
     do n=1,length-1
      call execRand(valueType,0,visible)
     end do
   !$omp end do
   !$omp end parallel
  else
   do n=1,length-1
    call execRand(valueType,0,visible)
   end do
  end if

 end if

end program random

subroutine execRand(valueType,seed,visible)
 character(len=10)::valueType
 integer seed
 logical visible
 character(len=10) container
 if (visible) then
  if (valueType=="real") then
   write (container,'(f10.8)') rand(seed)
  else if (valueType=="int") then
   write (container,'(i10)') irand(seed)
   ! 0≤x≤2147483647 の範囲の整数の乱数を生成する
  end if
  print '(a)',container
 else
  if (valueType=="real") then
   x=rand(seed)
  else if (valueType=="int") then
   x=irand(seed)
  end if
 end if
end subroutine

subroutine help()
 print *
 print *
 print '("使い方:")'
 print *
 print '(" random help")'
 print '("  このページを表示します")'
 print *
 print '(" random version")'
 print '("  このソフトウェアのバージョンを表示します")'
 print *
 print '(" random [options]")'
 print '("  以下のオプションに基づき乱数を生成します")'
 print *
 print '("  -l,-length : 生成する乱数の数を指定します (初期値:1)")'
 print *
 print '("  -i,-int : 整数の乱数を出力します")'
 print '("  -r,-real : 実数の乱数を出力します (初期値)")'
 print '("    0≤x<1の範囲の実数を出力します")'
 print *
 print '("  -parallel : 並列処理により乱数を生成します")'
 print '("  -hidden : 生成した乱数を表示しません (ベンチマーク等に最適)")'
 print *
 print *
end subroutine

subroutine version()
 print *
 print '("Random (Fortran version)")'
 print '("ビルド: 2019/7/31")'
 print *
 print '("Fortran で書かれた乱数生成システムです。")'
 print '("シェルから簡単に乱数を呼び出すことができます。")'
 print *
end subroutine