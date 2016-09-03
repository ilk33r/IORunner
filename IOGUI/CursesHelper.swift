//
//  CursesHelper.swift
//  IORunner/IOGUI
//
//  Created by ilker özcan on 10/08/16.
//
//

import Foundation

#if ONLY_USE_CURSES_ASCII
	extension String {
		
		func ToAscii() -> String {
			
			let allCharacters: [UInt32] = self.unicodeScalars.map{$0.value}
			var responseString: String = ""
			
			for character in allCharacters {
				
				if(character <= 127) {
					
					responseString += String(describing: UnicodeScalar(character)!)
				}else if(character == 228 || character == 230 || character == 509) {
					
					//ä æ ǽ
					responseString += "ae"
				}else if(character == 339) {
					
					//œ
					responseString += "oe"
				}else if(character == 192 || character == 193 || character == 194 || character == 195 || character == 196 || character == 197 || character == 506 || character == 256 || character == 258 || character == 260 || character == 461) {
					
					//À Á Â Ã Ä Å Ǻ Ā Ă Ą Ǎ
					responseString += "A"
				}else if(character == 224 || character == 225 || character == 226 || character == 227 || character == 229 || character == 507 || character == 257 || character == 259 || character == 261 || character == 462 || character == 170) {
					
					//à á â ã å ǻ ā ă ą ǎ ª
					responseString += "a"
				}else if(character == 199 || character == 262 || character == 264 || character == 266 || character == 268) {
					
					//Ç Ć Ĉ Ċ Č
					responseString += "C"
				}else if(character == 231 || character == 263 || character == 265 || character == 267 || character == 269) {
					
					//ç ć ĉ ċ č
					responseString += "c"
				}else if(character == 208 || character == 270 || character == 272) {
					
					//Ð Ď Đ
					responseString += "D"
				}else if(character == 240 || character == 271 || character == 273) {
					
					//ð ď đ
					responseString += "d"
				}else if(character == 200 || character == 201 || character == 202 || character == 203 || character == 274 || character == 276 || character == 278 || character == 280 || character == 282) {
					
					//È É Ê Ë Ē Ĕ Ė Ę Ě
					responseString += "E"
				}else if(character == 232 || character == 233 || character == 234 || character == 235 || character == 275 || character == 277 || character == 279 || character == 281 || character == 283) {
					
					//è é ê ë ē ĕ ė ę ě
					responseString += "e"
				}else if(character == 284 || character == 286 || character == 288 || character == 290) {
					
					//Ĝ Ğ Ġ Ģ
					responseString += "G"
				}else if(character == 285 || character == 287 || character == 289 || character == 291) {
					
					//ĝ ğ ġ ģ
					responseString += "g"
				}else if(character == 292 || character == 294) {
					
					//Ĥ Ħ
					responseString += "H"
				}else if(character == 293 || character == 295) {
					
					//ĥ ħ
					responseString += "h"
				}else if(character == 204 || character == 205 || character == 206 || character == 207 || character == 296 || character == 298 || character == 300 || character == 463 || character == 302 || character == 304) {
					
					//Ì Í Î Ï Ĩ Ī Ĭ Ǐ Į İ
					responseString += "I"
				}else if(character == 236 || character == 237 || character == 238 || character == 239 || character == 297 || character == 299 || character == 301 || character == 464 || character == 303 || character == 305) {
					
					//ì í î ï ĩ ī ĭ ǐ į ı
					responseString += "i"
				}else if(character == 308) {
					
					//Ĵ
					responseString += "J"
				}else if(character == 309) {
					
					//ĵ
					responseString += "j"
				}else if(character == 310) {
					
					//Ķ
					responseString += "K"
				}else if(character == 311) {
					
					//ķ
					responseString += "k"
				}else if(character == 313 || character == 315 || character == 317 || character == 319 || character == 321) {
					
					//Ĺ Ļ Ľ Ŀ Ł
					responseString += "L"
				}else if(character == 314 || character == 316 || character == 318 || character == 320 || character == 322) {
					
					//ĺ ļ ľ ŀ ł
					responseString += "l"
				}else if(character == 209 || character == 323 || character == 325 || character == 327) {
					
					//Ñ Ń Ņ Ň
					responseString += "N"
				}else if(character == 241 || character == 324 || character == 326 || character == 328 || character == 329) {
					
					//ñ ń ņ ň ŉ
					responseString += "n"
				}else if(character == 210 || character == 211 || character == 212 || character == 213 || character == 332 || character == 334 || character == 465 || character == 336 || character == 416 || character == 216 || character == 510 || character == 214) {
					
					//Ò Ó Ô Õ Ō Ŏ Ǒ Ő Ơ Ø Ǿ Ö
					responseString += "O"
				}else if(character == 242 || character == 243 || character == 244 || character == 245 || character == 333 || character == 335 || character == 466 || character == 337 || character == 417 || character == 248 || character == 511 || character == 186 || character == 246) {
					
					//ò ó ô õ ō ŏ ǒ ő ơ ø ǿ º ö
					responseString += "o"
				}else if(character == 340 || character == 342 || character == 344) {
					
					//Ŕ Ŗ Ř
					responseString += "R"
				}else if(character == 341 || character == 343 || character == 345) {
					
					//ŕ ŗ ř
					responseString += "r"
				}else if(character == 346 || character == 348 || character == 350 || character == 352) {
					
					//Ś Ŝ Ş Š
					responseString += "S"
				}else if(character == 347 || character == 349 || character == 351 || character == 353 || character == 383) {
					
					//ś ŝ ş š ſ
					responseString += "s"
				}else if(character == 254 || character == 356 || character == 358) {
					
					//Ţ Ť Ŧ
					responseString += "T"
				}else if(character == 355 || character == 357 || character == 359) {
					
					//ţ ť ŧ
					responseString += "t"
				}else if(character == 217 || character == 218 || character == 219 || character == 360 || character == 362 || character == 364 || character == 366 || character == 368 || character == 370 || character == 431 || character == 467 || character == 469 || character == 471 || character == 473 || character == 475 || character == 220) {
					
					//Ù Ú Û Ũ Ū Ŭ Ů Ű Ų Ư Ǔ Ǖ Ǘ Ǚ Ǜ Ü
					responseString += "U"
				}else if(character == 249 || character == 250 || character == 251 || character == 361 || character == 363 || character == 365 || character == 367 || character == 369 || character == 371 || character == 432 || character == 468 || character == 470 || character == 472 || character == 474 || character == 476 || character == 252) {
					
					//ù ú û ũ ū ŭ ů ű ų ư ǔ ǖ ǘ ǚ ǜ ü
					responseString += "u"
				}else if(character == 221 || character == 376 || character == 374) {
					
					//Ý Ÿ Ŷ
					responseString += "Y"
				}else if(character == 253 || character == 255 || character == 375) {
					
					//ý ÿ ŷ
					responseString += "y"
				}else if(character == 372) {
					
					//Ŵ
					responseString += "W"
				}else if(character == 373) {
					
					//ŵ
					responseString += "w"
				}else if(character == 377 || character == 379 || character == 381) {
					
					//Ź Ż Ž
					responseString += "Z"
				}else if(character == 378 || character == 380 || character == 382) {
					
					//ź ż ž
					responseString += "z"
				}else if(character == 198 || character == 508) {
					
					//Æ Ǽ
					responseString += "AE"
				}else if(character == 223) {
					
					//ß
					responseString += "ss"
				}else if(character == 306) {
					
					//Ĳ
					responseString += "IJ"
				}else if(character == 307) {
					
					//ĳ
					responseString += "ij"
				}else if(character == 338) {
					
					//Œ
					responseString += "OE"
				}else if(character == 402) {
					
					//ƒ
					responseString += "f"
				}else if(character == 8594) {
					
					//→
					responseString += "->"
				}else{
					responseString += "-"
				}
			}
			
			return responseString
		}
	}
#else
	extension String {
		
		func ToAscii() -> String {
			
			return self
		}
	}
#endif

#if os(OSX)
#if swift(>=3)
	func AddStringToWindow(normalString string: String, window: OpaquePointer) {
		
		waddstr(window, string.ToAscii())
	}
	
	func AddStringToWindow(paddingString string: String, textWidth: Int, textStartSpace: Int, window: OpaquePointer) {
		
		let asciiString = string.ToAscii()
		var paddingSize = textWidth - asciiString.characters.count - textStartSpace
		if paddingSize < 0 {
			paddingSize = 0
		}
		
		let stringStartPadding = String(repeating: " ", count: textStartSpace)
		let stringEndPadding = String(repeating: " ", count: paddingSize)
		let resultString = "\(stringStartPadding)\(asciiString)\(stringEndPadding)"
		waddstr(window, resultString)
	}
#else
	func AddStringToWindow(normalString string: String, window: COpaquePointer) {
	
		waddstr(window, string.ToAscii())
	}
	
	func AddStringToWindow(paddingString string: String, textWidth: Int, textStartSpace: Int, window: COpaquePointer) {
	
		let asciiString = string.ToAscii()
		var paddingSize = textWidth - asciiString.characters.count - textStartSpace
		if paddingSize < 0 {
			paddingSize = 0
		}
	
		let stringStartPadding = String(count: textStartSpace, repeatedValue: Character(" "))
		let stringEndPadding = String(count: paddingSize, repeatedValue: Character(" "))
		let resultString = "\(stringStartPadding)\(asciiString)\(stringEndPadding)"
		waddstr(window, resultString)
	}
#endif
#elseif os(Linux)
	func AddStringToWindow(normalString string: String, window: UnsafeMutablePointer<WINDOW>) {
		
		waddstr(window, string.ToAscii())
	}
	
	func AddStringToWindow(paddingString string: String, textWidth: Int, textStartSpace: Int, window: UnsafeMutablePointer<WINDOW>) {
		
		let asciiString = string.ToAscii()
		var paddingSize = textWidth - asciiString.characters.count - textStartSpace
		if paddingSize < 0 {
			paddingSize = 0
		}
		
		let stringStartPadding = String(repeating: " ", count: textStartSpace)
		let stringEndPadding = String(repeating: " ", count: paddingSize)
		let resultString: String = "\(stringStartPadding)\(asciiString)\(stringEndPadding)"
		waddstr(window, resultString)
	}
#else
	func AddStringToWindow(normalString string: String, window: OpaquePointer) {
		
		abort()
	}
#endif

