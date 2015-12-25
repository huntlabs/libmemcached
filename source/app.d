import std.stdio;
import collie.libmemcache4d.memcache;
import std.string;

void main() {
	Memcache mem = new Memcache("127.0.0.1",1025);
	writeln("get maomao = ",mem.get("maomao"));
	string erro;
	if (mem.error(erro)) {
		writeln("erro = ",erro);
	} 
	string value = "hahah\r\n";
	writeln("set len = " ,mem.set("maomao",value));

	writeln("get maomao = ",mem.get("maomao"));
	if (mem.error(erro)) {
		writeln("erro = ",erro);
	}

	writeln("get maomao = ",mem.get("mao"));

	writeln("set len = " ,mem.set("maoo",value));

	writeln("get maomao = ",mem.get("maoo"));

}