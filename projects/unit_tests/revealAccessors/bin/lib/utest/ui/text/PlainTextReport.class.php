<?php

class utest_ui_text_PlainTextReport implements utest_ui_common_IReport{
	public function __construct($runner, $outputHandler) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("utest.ui.text.PlainTextReport::new");
		$»spos = $GLOBALS['%s']->length;
		$this->aggregator = new utest_ui_common_ResultAggregator($runner, true);
		$runner->onStart->add((isset($this->start) ? $this->start: array($this, "start")));
		$this->aggregator->onComplete->add((isset($this->complete) ? $this->complete: array($this, "complete")));
		if(null !== $outputHandler) {
			$this->setHandler($outputHandler);
		}
		$this->displaySuccessResults = utest_ui_common_SuccessResultsDisplayMode::$AlwaysShowSuccessResults;
		$this->displayHeader = utest_ui_common_HeaderDisplayMode::$AlwaysShowHeader;
		$GLOBALS['%s']->pop();
	}}
	public $displaySuccessResults;
	public $displayHeader;
	public $handler;
	public $aggregator;
	public $newline;
	public $indent;
	public function setHandler($handler) {
		$GLOBALS['%s']->push("utest.ui.text.PlainTextReport::setHandler");
		$»spos = $GLOBALS['%s']->length;
		$this->handler = $handler;
		$GLOBALS['%s']->pop();
	}
	public $startTime;
	public function start($e) {
		$GLOBALS['%s']->push("utest.ui.text.PlainTextReport::start");
		$»spos = $GLOBALS['%s']->length;
		$this->startTime = haxe_Timer::stamp();
		$GLOBALS['%s']->pop();
	}
	public function indents($c) {
		$GLOBALS['%s']->push("utest.ui.text.PlainTextReport::indents");
		$»spos = $GLOBALS['%s']->length;
		$s = "";
		{
			$_g = 0;
			while($_g < $c) {
				$_ = $_g++;
				$s .= $this->indent;
				unset($_);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $s;
		}
		$GLOBALS['%s']->pop();
	}
	public function dumpStack($stack) {
		$GLOBALS['%s']->push("utest.ui.text.PlainTextReport::dumpStack");
		$»spos = $GLOBALS['%s']->length;
		if($stack->length === 0) {
			$GLOBALS['%s']->pop();
			return "";
		}
		$parts = _hx_explode("\x0A", haxe_Stack::toString($stack));
		$r = new _hx_array(array());
		{
			$_g = 0;
			while($_g < $parts->length) {
				$part = $parts[$_g];
				++$_g;
				if(_hx_index_of($part, " utest.", null) >= 0) {
					continue;
				}
				$r->push($part);
				unset($part);
			}
		}
		{
			$»tmp = $r->join($this->newline);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function addHeader($buf, $result) {
		$GLOBALS['%s']->push("utest.ui.text.PlainTextReport::addHeader");
		$»spos = $GLOBALS['%s']->length;
		if(!utest_ui_common_ReportTools::hasHeader($this, $result->stats)) {
			$GLOBALS['%s']->pop();
			return;
		}
		$end = haxe_Timer::stamp();
		$scripttime = intval(php_Sys::cpuTime() * 1000) / 1000;
		$time = intval(($end - $this->startTime) * 1000) / 1000;
		$buf->b .= "results: " . ((($result->stats->isOk) ? "ALL TESTS OK" : "SOME TESTS FAILURES")) . $this->newline . " " . $this->newline;
		$buf->b .= "assertations: " . $result->stats->assertations . $this->newline;
		$buf->b .= "successes: " . $result->stats->successes . $this->newline;
		$buf->b .= "errors: " . $result->stats->errors . $this->newline;
		$buf->b .= "failures: " . $result->stats->failures . $this->newline;
		$buf->b .= "warnings: " . $result->stats->warnings . $this->newline;
		$buf->b .= "execution time: " . $time . $this->newline;
		$buf->b .= "script time: " . $scripttime . $this->newline;
		$buf->b .= $this->newline;
		$GLOBALS['%s']->pop();
	}
	public $result;
	public function getResults() {
		$GLOBALS['%s']->push("utest.ui.text.PlainTextReport::getResults");
		$»spos = $GLOBALS['%s']->length;
		$buf = new StringBuf();
		$this->addHeader($buf, $this->result);
		{
			$_g = 0; $_g1 = $this->result->packageNames(null);
			while($_g < $_g1->length) {
				$pname = $_g1[$_g];
				++$_g;
				$pack = $this->result->getPackage($pname);
				if(utest_ui_common_ReportTools::skipResult($this, $pack->stats, $this->result->stats->isOk)) {
					continue;
				}
				{
					$_g2 = 0; $_g3 = $pack->classNames(null);
					while($_g2 < $_g3->length) {
						$cname = $_g3[$_g2];
						++$_g2;
						$cls = $pack->getClass($cname);
						if(utest_ui_common_ReportTools::skipResult($this, $cls->stats, $this->result->stats->isOk)) {
							continue;
						}
						$buf->b .= (utest_ui_text_PlainTextReport_0($this, $_g, $_g1, $_g2, $_g3, $buf, $cls, $cname, $pack, $pname)) . $cname . $this->newline;
						{
							$_g4 = 0; $_g5 = $cls->methodNames(null);
							while($_g4 < $_g5->length) {
								$mname = $_g5[$_g4];
								++$_g4;
								$fix = $cls->get($mname);
								if(utest_ui_common_ReportTools::skipResult($this, $fix->stats, $this->result->stats->isOk)) {
									continue;
								}
								$buf->b .= $this->indents(1) . $mname . ": ";
								if($fix->stats->isOk) {
									$buf->b .= "OK ";
								} else {
									if($fix->stats->hasErrors) {
										$buf->b .= "ERROR ";
									} else {
										if($fix->stats->hasFailures) {
											$buf->b .= "FAILURE ";
										} else {
											if($fix->stats->hasWarnings) {
												$buf->b .= "WARNING ";
											}
										}
									}
								}
								$messages = "";
								if(null == $fix) throw new HException('null iterable');
								$»it = $fix->iterator();
								while($»it->hasNext()) {
									$assertation = $»it->next();
									$»t = ($assertation);
									switch($»t->index) {
									case 0:
									$pos = $»t->params[0];
									{
										$buf->b .= ".";
									}break;
									case 1:
									$pos = $»t->params[1]; $msg = $»t->params[0];
									{
										$buf->b .= "F";
										$messages .= $this->indents(2) . "line: " . $pos->lineNumber . ", " . $msg . $this->newline;
									}break;
									case 2:
									$s = $»t->params[1]; $e = $»t->params[0];
									{
										$buf->b .= "E";
										$messages .= $this->indents(2) . Std::string($e) . $this->dumpStack($s) . $this->newline;
									}break;
									case 3:
									$s = $»t->params[1]; $e = $»t->params[0];
									{
										$buf->b .= "S";
										$messages .= $this->indents(2) . Std::string($e) . $this->dumpStack($s) . $this->newline;
									}break;
									case 4:
									$s = $»t->params[1]; $e = $»t->params[0];
									{
										$buf->b .= "T";
										$messages .= $this->indents(2) . Std::string($e) . $this->dumpStack($s) . $this->newline;
									}break;
									case 5:
									$s = $»t->params[1]; $missedAsyncs = $»t->params[0];
									{
										$buf->b .= "O";
										$messages .= $this->indents(2) . "missed async calls: " . $missedAsyncs . $this->dumpStack($s) . $this->newline;
									}break;
									case 6:
									$s = $»t->params[1]; $e = $»t->params[0];
									{
										$buf->b .= "A";
										$messages .= $this->indents(2) . Std::string($e) . $this->dumpStack($s) . $this->newline;
									}break;
									case 7:
									$msg = $»t->params[0];
									{
										$buf->b .= "W";
										$messages .= $this->indents(2) . $msg . $this->newline;
									}break;
									}
								}
								$buf->b .= $this->newline;
								$buf->b .= $messages;
								unset($mname,$messages,$fix);
							}
							unset($_g5,$_g4);
						}
						unset($cname,$cls);
					}
					unset($_g3,$_g2);
				}
				unset($pname,$pack);
			}
		}
		{
			$»tmp = $buf->b;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function complete($result) {
		$GLOBALS['%s']->push("utest.ui.text.PlainTextReport::complete");
		$»spos = $GLOBALS['%s']->length;
		$this->result = $result;
		$this->handler($this);
		$GLOBALS['%s']->pop();
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->»dynamics[$m]) && is_callable($this->»dynamics[$m]))
			return call_user_func_array($this->»dynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call «'.$m.'»');
	}
	function __toString() { return 'utest.ui.text.PlainTextReport'; }
}
function utest_ui_text_PlainTextReport_0(&$»this, &$_g, &$_g1, &$_g2, &$_g3, &$buf, &$cls, &$cname, &$pack, &$pname) {
	$»spos = $GLOBALS['%s']->length;
	if($pname === "") {
		return "";
	} else {
		return $pname . ".";
	}
}
