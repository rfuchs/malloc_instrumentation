my %a;

while (<>) {
	/^\Q|||||||||||||||||||||| [\E/ or next;
	my ($caller, $call, $args, $res) = /^\Q|||||||||||||||||||||| [\E0x[0-9a-f]+\]: (.*?): (\w+)\((.*?)\)(?: = (.*?))?$/ or die $_;
	my $chunk = "$caller -- $size";
	if ($call eq 'malloc' || $call eq 'calloc') {
		$a{$res} = $chunk;
		next;
	}
	if ($call eq 'free') {
		delete $a{$args};
		next;
	}
	if ($call eq 'realloc') {
		my ($ori, $size) = $args =~ /(.*), (.*)/ or die $_;
		delete $a{$ori};
		$a{$res} = $chunk;
		next;
	}
	if ($call eq 'posix_memalign') {
		my ($code, $ptr) = $res =~ /(.*), (.*)/ or die $_;
		$a{$ptr} = $chunk;
		next;
	}
	die $_;
}

for my $k (keys(%a)) {
	print("$k => $a{$k}\n");
}
