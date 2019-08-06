pub fn help() {
	println!(r"
使い方

 random help
  このページを表示します

 random version
  このソフトウェアのバージョンを表示します

 random [options]
  以下のオプションに基づき乱数を生成します

  -m,-mode [string] : 乱数生成方法を指定します (初期値:OS)
    TRNG (真の乱数)
      • OS
          Unixの /dev/random などの乱数生成源から乱数を生成します
      • Jitter
      • Thread
    CSPRING (暗号論的擬似乱数生成器)
      • Standard
          安全な乱数を以下の生成器から選択して生成します
      • ChaCha20
      • ChaCha12
      • ChaCha8
      • Hc128 (HC-128)
      • Isaac (ISAAC)
      • Isaac64 (ISAAC-64)
    PRNG (擬似乱数生成器)
      • Lcg128 (PCG XSL 128/64 (LCG))
      • Lcg64 (PCG XSH RR 64/32 (LCG))
      • Mcg128 (PCG XSL 128/64 (MCG))
      • XorShift (Xorshift 32/128)
      • Xoroshiro64**
      • Xoroshiro64*
      • Xoroshiro128**
      • Xoroshiro128+
      • Xoshiro128**
      • Xoshiro128+
      • Xoshiro256**
      • Xoshiro256+
      • Xoshiro512**
      • Xoshiro512+
      • SplitMix64
    テスト用
      • Step
          指定したステップを足していくだけです
          -s で初期値を, -d で増分を指定します

  -s,-seed [string|int] : 乱数のシードを指定します (初期値:OS)
   CSPRNG,PRNGでの乱数生成に必要なシードを指定します
    TRNGによるシード: TRNGの乱数をシードとして利用します
      • OS
          -m OS で得られる乱数をシードとして利用します
      • Jitter
          -m Jitter で得られる乱数をシードとして利用します
      • Thread
          -m Thread で得られる乱数をシードとして利用します
    その他のシード
      • Time
          現在時刻 (Unixエポック) に基づくシードを指定します
      • [int]
          0以上の整数をシードとして与えます

    ※ 全ての乱数生成器で初期値は OS になっていますが, -m Step の場合だけ 0 が初期値になっています

  -l,-length : 生成する乱数の数を指定します (初期値:1)

  -r,-real [min] [max] : 実数の乱数を出力します (初期値)
   min,maxを指定すると, min≤x<max の範囲内の値に絞ります
   指定しない場合は,0≤x<1の範囲の実数を出力します

  -i,-int [min] [max] : 整数の乱数を出力します
   min,maxを指定すると, min≤x≤max の範囲内の値に絞ります
   指定しない場合は,0 ~ 2⁶⁴-1 の範囲の乱数になります
   -m Stepの場合はこちらが初期値になります

  -hidden : 生成した乱数を表示しません (ベンチマーク等に最適)

  -d [int] : 増分を指定します (初期値:1)
   -m Step の場合のみこのオプションは有効です
   0以上の整数を指定します

")
}

pub fn version() {
	println!("
Random (Rust version)
ビルド: 2019/7/31

Rust で書かれた乱数生成システムです。
シェルから簡単に乱数を呼び出すことができます。
")
}