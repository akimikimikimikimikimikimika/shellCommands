package main

import "fmt"
import "sync"
import "os"
import "strconv"
import "time"
import "math"
import big "math/big"
import rand "math/rand"
import cRand "crypto/rand"

func main() {

	args := os.Args

	if len(args)>1 {
		if args[1]=="help" {
			help()
			os.Exit(0)
		}
		if args[1]=="version" {
			version()
			os.Exit(0)
		}
	}

	var seed string = "time"
	var valueType string = "real"
	var length uint64 = 1
	var concurrent bool = false
	var visible bool = true

	var responder string = ""
	for _,c := range args {
		if c=="-s" || c=="-seed" {
			responder="seed"
		} else if c=="-l" || c=="-length" {
			responder="length"
		} else if c=="-i" || c=="-int" {
			valueType="int"
		} else if c=="-r" || c=="-real" {
			valueType="real"
		} else if c=="-n" || c=="-norm" {
			valueType="norm"
		} else if c=="-parallel" {
			concurrent=true
		} else if c=="-hidden" || c=="-invisible" {
			visible=false
		} else if responder=="seed" {
			if c=="none" {
				seed="none"
				responder=""
			} else if c=="time" {
				seed="time"
				responder=""
			} else if c=="crypto" {
				seed="crypto"
				responder=""
			} else {
				fmt.Println("引数が不正です: ",c)
				os.Exit(1)
			}
		} else if responder=="length" {
			v,_:=strconv.Atoi(c)
			length=uint64(v)
			responder=""
		}
	}

	if seed == "time" {
		rand.Seed(time.Now().UnixNano())
	} else if seed == "crypto" {
		s,_ := cRand.Int(cRand.Reader, big.NewInt(math.MaxInt64))
		rand.Seed(s.Int64())
	}

	if valueType=="int" {
		if visible {
			quickLoop(func(){fmt.Println(rand.Int())},concurrent,length)
		} else {
			quickLoop(func(){rand.Int()},concurrent,length)
		}
	}
	if valueType=="real" {
		if visible {
			quickLoop(func(){fmt.Println(rand.Float64())},concurrent,length)
		} else {
			quickLoop(func(){rand.Float64()},concurrent,length)
		}
	}
	if valueType=="norm" {
		if visible {
			quickLoop(func(){fmt.Println(rand.NormFloat64())},concurrent,length)
		} else {
			quickLoop(func(){rand.NormFloat64()},concurrent,length)
		}
	}

}

func quickLoop(f func(),concurrent bool,max uint64) {
	var n uint64
	if concurrent {
		wg := &sync.WaitGroup{}
		for n=0;n<max;n++ {
			wg.Add(1)
			go func() {
				f()
				wg.Done()
			} ()
		}
		wg.Wait()
	} else {
		for n=0;n<max;n++ {f()}
	}
}

func help() {
	fmt.Println(`
使い方

 random help
  このページを表示します

 random version
  このソフトウェアのバージョンを表示します

 random [option]
  以下のオプションに基づき乱数を生成します

  -s [string|int] : 乱数シードを指定 (初期値:time)
   • none : シードを与えない
     このオプションでは常に同じ乱数が生成される可能性があります
   • time
      現在時刻をシードに乱数を生成します
   • crypto
	  よりセキュアなシードを利用します

  -l,-length [int] : 生成する乱数の数を指定 (初期値:1)

  -i,-int : 整数の乱数を出力します
  -r,-real : [0,1) の実数の乱数を出力します
  -n,-norm : 標準正規分布に従う実数を出力します

  -parallel : 並列処理により乱数を生成します
  -hidden : 生成した乱数を表示しません (ベンチマーク等に最適)

`)
}

func version() {
	fmt.Println(`

Random (Go version)
ビルド: 2019/8/1

Go で書かれた乱数生成システムです。
シェルから簡単に乱数を呼び出すことができます。

`)
}