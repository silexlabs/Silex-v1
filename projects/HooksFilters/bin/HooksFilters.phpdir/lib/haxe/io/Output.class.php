<?php

class haxe_io_Output {
	public function __construct(){}
	public $bigEndian;
	public function writeByte($c) {
		$GLOBALS['%s']->push("haxe.io.Output::writeByte");
		$製pos = $GLOBALS['%s']->length;
		throw new HException("Not implemented");
		$GLOBALS['%s']->pop();
	}
	public function writeBytes($s, $pos, $len) {
		$GLOBALS['%s']->push("haxe.io.Output::writeBytes");
		$製pos = $GLOBALS['%s']->length;
		$k = $len;
		$b = $s->b;
		if($pos < 0 || $len < 0 || $pos + $len > $s->length) {
			throw new HException(haxe_io_Error::$OutsideBounds);
		}
		while($k > 0) {
			$this->writeByte(ord($b[$pos]));
			$pos++;
			$k--;
		}
		{
			$GLOBALS['%s']->pop();
			return $len;
		}
		$GLOBALS['%s']->pop();
	}
	public function flush() {
		$GLOBALS['%s']->push("haxe.io.Output::flush");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
	public function close() {
		$GLOBALS['%s']->push("haxe.io.Output::close");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
	public function setEndian($b) {
		$GLOBALS['%s']->push("haxe.io.Output::setEndian");
		$製pos = $GLOBALS['%s']->length;
		$this->bigEndian = $b;
		{
			$GLOBALS['%s']->pop();
			return $b;
		}
		$GLOBALS['%s']->pop();
	}
	public function write($s) {
		$GLOBALS['%s']->push("haxe.io.Output::write");
		$製pos = $GLOBALS['%s']->length;
		$l = $s->length;
		$p = 0;
		while($l > 0) {
			$k = $this->writeBytes($s, $p, $l);
			if($k === 0) {
				throw new HException(haxe_io_Error::$Blocked);
			}
			$p += $k;
			$l -= $k;
			unset($k);
		}
		$GLOBALS['%s']->pop();
	}
	public function writeFullBytes($s, $pos, $len) {
		$GLOBALS['%s']->push("haxe.io.Output::writeFullBytes");
		$製pos = $GLOBALS['%s']->length;
		while($len > 0) {
			$k = $this->writeBytes($s, $pos, $len);
			$pos += $k;
			$len -= $k;
			unset($k);
		}
		$GLOBALS['%s']->pop();
	}
	public function writeFloat($x) {
		$GLOBALS['%s']->push("haxe.io.Output::writeFloat");
		$製pos = $GLOBALS['%s']->length;
		$this->write(haxe_io_Bytes::ofString(pack("f", $x)));
		$GLOBALS['%s']->pop();
	}
	public function writeDouble($x) {
		$GLOBALS['%s']->push("haxe.io.Output::writeDouble");
		$製pos = $GLOBALS['%s']->length;
		$this->write(haxe_io_Bytes::ofString(pack("d", $x)));
		$GLOBALS['%s']->pop();
	}
	public function writeInt8($x) {
		$GLOBALS['%s']->push("haxe.io.Output::writeInt8");
		$製pos = $GLOBALS['%s']->length;
		if($x < -128 || $x >= 128) {
			throw new HException(haxe_io_Error::$Overflow);
		}
		$this->writeByte($x & 255);
		$GLOBALS['%s']->pop();
	}
	public function writeInt16($x) {
		$GLOBALS['%s']->push("haxe.io.Output::writeInt16");
		$製pos = $GLOBALS['%s']->length;
		if($x < -32768 || $x >= 32768) {
			throw new HException(haxe_io_Error::$Overflow);
		}
		$this->writeUInt16($x & 65535);
		$GLOBALS['%s']->pop();
	}
	public function writeUInt16($x) {
		$GLOBALS['%s']->push("haxe.io.Output::writeUInt16");
		$製pos = $GLOBALS['%s']->length;
		if($x < 0 || $x >= 65536) {
			throw new HException(haxe_io_Error::$Overflow);
		}
		if($this->bigEndian) {
			$this->writeByte($x >> 8);
			$this->writeByte($x & 255);
		} else {
			$this->writeByte($x & 255);
			$this->writeByte($x >> 8);
		}
		$GLOBALS['%s']->pop();
	}
	public function writeInt24($x) {
		$GLOBALS['%s']->push("haxe.io.Output::writeInt24");
		$製pos = $GLOBALS['%s']->length;
		if($x < -8388608 || $x >= 8388608) {
			throw new HException(haxe_io_Error::$Overflow);
		}
		$this->writeUInt24($x & 16777215);
		$GLOBALS['%s']->pop();
	}
	public function writeUInt24($x) {
		$GLOBALS['%s']->push("haxe.io.Output::writeUInt24");
		$製pos = $GLOBALS['%s']->length;
		if($x < 0 || $x >= 16777216) {
			throw new HException(haxe_io_Error::$Overflow);
		}
		if($this->bigEndian) {
			$this->writeByte($x >> 16);
			$this->writeByte($x >> 8 & 255);
			$this->writeByte($x & 255);
		} else {
			$this->writeByte($x & 255);
			$this->writeByte($x >> 8 & 255);
			$this->writeByte($x >> 16);
		}
		$GLOBALS['%s']->pop();
	}
	public function writeInt31($x) {
		$GLOBALS['%s']->push("haxe.io.Output::writeInt31");
		$製pos = $GLOBALS['%s']->length;
		if($x < -1073741824 || $x >= 1073741824) {
			throw new HException(haxe_io_Error::$Overflow);
		}
		if($this->bigEndian) {
			$this->writeByte(_hx_shift_right($x, 24));
			$this->writeByte($x >> 16 & 255);
			$this->writeByte($x >> 8 & 255);
			$this->writeByte($x & 255);
		} else {
			$this->writeByte($x & 255);
			$this->writeByte($x >> 8 & 255);
			$this->writeByte($x >> 16 & 255);
			$this->writeByte(_hx_shift_right($x, 24));
		}
		$GLOBALS['%s']->pop();
	}
	public function writeUInt30($x) {
		$GLOBALS['%s']->push("haxe.io.Output::writeUInt30");
		$製pos = $GLOBALS['%s']->length;
		if($x < 0 || $x >= 1073741824) {
			throw new HException(haxe_io_Error::$Overflow);
		}
		if($this->bigEndian) {
			$this->writeByte(_hx_shift_right($x, 24));
			$this->writeByte($x >> 16 & 255);
			$this->writeByte($x >> 8 & 255);
			$this->writeByte($x & 255);
		} else {
			$this->writeByte($x & 255);
			$this->writeByte($x >> 8 & 255);
			$this->writeByte($x >> 16 & 255);
			$this->writeByte(_hx_shift_right($x, 24));
		}
		$GLOBALS['%s']->pop();
	}
	public function writeInt32($x) {
		$GLOBALS['%s']->push("haxe.io.Output::writeInt32");
		$製pos = $GLOBALS['%s']->length;
		if($this->bigEndian) {
			$this->writeByte(haxe_io_Output_0($this, $x));
			$this->writeByte(haxe_io_Output_1($this, $x) & 255);
			$this->writeByte(haxe_io_Output_2($this, $x) & 255);
			$this->writeByte(haxe_io_Output_3($this, $x));
		} else {
			$this->writeByte(haxe_io_Output_4($this, $x));
			$this->writeByte(haxe_io_Output_5($this, $x) & 255);
			$this->writeByte(haxe_io_Output_6($this, $x) & 255);
			$this->writeByte(haxe_io_Output_7($this, $x));
		}
		$GLOBALS['%s']->pop();
	}
	public function prepare($nbytes) {
		$GLOBALS['%s']->push("haxe.io.Output::prepare");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
	public function writeInput($i, $bufsize) {
		$GLOBALS['%s']->push("haxe.io.Output::writeInput");
		$製pos = $GLOBALS['%s']->length;
		if($bufsize === null) {
			$bufsize = 4096;
		}
		$buf = haxe_io_Bytes::alloc($bufsize);
		try {
			while(true) {
				$len = $i->readBytes($buf, 0, $bufsize);
				if($len === 0) {
					throw new HException(haxe_io_Error::$Blocked);
				}
				$p = 0;
				while($len > 0) {
					$k = $this->writeBytes($buf, $p, $len);
					if($k === 0) {
						throw new HException(haxe_io_Error::$Blocked);
					}
					$p += $k;
					$len -= $k;
					unset($k);
				}
				unset($p,$len);
			}
		}catch(Exception $蜜) {
			$_ex_ = ($蜜 instanceof HException) ? $蜜->e : $蜜;
			if(($e = $_ex_) instanceof haxe_io_Eof){
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $製pos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
			} else throw $蜜;;
		}
		$GLOBALS['%s']->pop();
	}
	public function writeString($s) {
		$GLOBALS['%s']->push("haxe.io.Output::writeString");
		$製pos = $GLOBALS['%s']->length;
		$b = haxe_io_Bytes::ofString($s);
		$this->writeFullBytes($b, 0, $b->length);
		$GLOBALS['%s']->pop();
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->蜿ynamics[$m]) && is_callable($this->蜿ynamics[$m]))
			return call_user_func_array($this->蜿ynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call �'.$m.'�');
	}
	function __toString() { return 'haxe.io.Output'; }
}
function haxe_io_Output_0(&$裨his, &$x) {
		$GLOBALS['%s']->push('haxe.io.Output:lambda_0');
		$製pos = $GLOBALS['%s']->length;
	{
		$x1 = _hx_shift_right($x, 24);
		if(($x1 >> 30 & 1) !== _hx_shift_right($x1, 31)) {
			throw new HException("Overflow " . $x1);
		}
		return $x1 & -1;
	}
}
function haxe_io_Output_1(&$裨his, &$x) {
		$GLOBALS['%s']->push('haxe.io.Output:lambda_1');
		$製pos = $GLOBALS['%s']->length;
	{
		$x1 = _hx_shift_right($x, 16);
		if(($x1 >> 30 & 1) !== _hx_shift_right($x1, 31)) {
			throw new HException("Overflow " . $x1);
		}
		return $x1 & -1;
	}
}
function haxe_io_Output_2(&$裨his, &$x) {
		$GLOBALS['%s']->push('haxe.io.Output:lambda_2');
		$製pos = $GLOBALS['%s']->length;
	{
		$x1 = _hx_shift_right($x, 8);
		if(($x1 >> 30 & 1) !== _hx_shift_right($x1, 31)) {
			throw new HException("Overflow " . $x1);
		}
		return $x1 & -1;
	}
}
function haxe_io_Output_3(&$裨his, &$x) {
		$GLOBALS['%s']->push('haxe.io.Output:lambda_3');
		$製pos = $GLOBALS['%s']->length;
	{
		$x1 = $x & 255;
		if(($x1 >> 30 & 1) !== _hx_shift_right($x1, 31)) {
			throw new HException("Overflow " . $x1);
		}
		return $x1 & -1;
	}
}
function haxe_io_Output_4(&$裨his, &$x) {
		$GLOBALS['%s']->push('haxe.io.Output:lambda_4');
		$製pos = $GLOBALS['%s']->length;
	{
		$x1 = $x & 255;
		if(($x1 >> 30 & 1) !== _hx_shift_right($x1, 31)) {
			throw new HException("Overflow " . $x1);
		}
		return $x1 & -1;
	}
}
function haxe_io_Output_5(&$裨his, &$x) {
		$GLOBALS['%s']->push('haxe.io.Output:lambda_5');
		$製pos = $GLOBALS['%s']->length;
	{
		$x1 = _hx_shift_right($x, 8);
		if(($x1 >> 30 & 1) !== _hx_shift_right($x1, 31)) {
			throw new HException("Overflow " . $x1);
		}
		return $x1 & -1;
	}
}
function haxe_io_Output_6(&$裨his, &$x) {
		$GLOBALS['%s']->push('haxe.io.Output:lambda_6');
		$製pos = $GLOBALS['%s']->length;
	{
		$x1 = _hx_shift_right($x, 16);
		if(($x1 >> 30 & 1) !== _hx_shift_right($x1, 31)) {
			throw new HException("Overflow " . $x1);
		}
		return $x1 & -1;
	}
}
function haxe_io_Output_7(&$裨his, &$x) {
		$GLOBALS['%s']->push('haxe.io.Output:lambda_7');
		$製pos = $GLOBALS['%s']->length;
	{
		$x1 = _hx_shift_right($x, 24);
		if(($x1 >> 30 & 1) !== _hx_shift_right($x1, 31)) {
			throw new HException("Overflow " . $x1);
		}
		return $x1 & -1;
	}
}
