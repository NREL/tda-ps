#!/usr/bin/env bash

export TMPDIR=~/tmp 
FILE=$(mktemp -p $TMPDIR)

while read f
do
  grep -E '(Status|LIMITS|LOCALLY_SOLVED)' $f >> $FILE
done < <(find -name result-\*.tsv)

sort -k121 -k122 -k123 -k124 -k125 -k126 -k127 -k128 -k129 -k130 -k131 -k132 -k133 -k134 -k135 -k136 -k137 -k138 -k139 -k140 -k141 -k142 -k143 -k144 -k145 -k146 -k147 -k148 -k149 -k150 -k151 -k152 -k153 -k154 -k155 -k156 -k157 -k158 -k159 -k160 -k161 -k162 -k163 -k164 -k165 -k166 -k167 -k168 -k169 -k170 -k171 -k172 -k173 -k174 -k175 -k176 -k177 -k178 -k179 -k180 -k181 -k182 -k183 -k184 -k185 -k186 -k187 -k188 -k189 -k190 -k191 -k192 -k193 -k194 -k195 -k196 -k197 -k198 -k199 -k200 -k201 -k202 -k203 -k204 -k205 -k206 -k207 -k208 -k209 -k210 -k211 -k212 -k213 -k214 -k215 -k216 -k217 -k218 -k219 -k220 -k221 -k222 -k223 -k224 -k225 -k226 -k227 -k228 -k229 -k230 -k231 -k232 -k233 -k234 -k235 -k236 -k237 -k238 -k239 -k240 -k241 -k242 -k243 -k244 -k245 -k246 -k247 -k248 -k249 -k250 -k251 -k252 -k253 -k254 -k255 -k256 -k257 -k258 -k259 -k260 -k261 -k262 -k263 -k264 -k265 -k266 -k267 -k268 -k269 -k270 -k271 -k272 -k273 -k274 -k275 -k276 -k277 -k278 -k279 -k280 -k281 -k282 -k283 -k284 -k285 -k286 -k287 -k288 -k289 -k290 -k291 -k292 -k293 -k294 -k295 -k296 -k297 -k298 -k299 -k300 -k301 -k302 -k303 -k304 -k305 -k306 -k1n -u -T $TMPDIR $FILE -o unique.tsv

rm $FILE

zip -9 unique.zip unique.tsv
