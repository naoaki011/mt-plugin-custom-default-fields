#   Copyright (c) 2008 ToI-Planning, All rights reserved.
# 
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions
#   are met:
# 
#   1. Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#
#   2. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#
#   3. Neither the name of the authors nor the names of its contributors
#      may be used to endorse or promote products derived from this
#      software without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
#   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#  $Id: App.pm 12 2008-10-30 01:25:54Z usualoma $

package CustomDefaultFields::App;
use strict;
use File::Basename;

sub source_edit_entry {
	my ($cb, $app, $tmpl) = @_;
	my $plugin = MT->component('CustomDefaultFields');
	my $blog_id = $app->param('blog_id') or return;

	my $hash = $plugin->get_config_hash('blog:' . $blog_id) || {};

	# editing web page
	if ($app->param('_type') eq 'page') {
		foreach my $k (%$hash) {
			if ($k =~ m/^page_(.*)/) {
				$hash->{$1} = $hash->{$k};
			}
		}
	}

	my $style = '';

	if ($hash->{'hide_title'}) {
		$style .= <<__EOH__;
#title-field {
	position: absolute;
	z-index: -1;
}
__EOH__
	}
	else {
		if (my $label = $hash->{'title_label'}) {
			$$tmpl =~ s/<__trans phrase="Title">/$label/g;
		}
		if ($hash->{'title_is_textarea'}) {
			my ($input) = ($$tmpl =~ m/(<input(.(?!\/>))*?id="title"(.(?!\/>))*?.\/>)/i);
			my ($value) = ($input =~ m/value="([^"]*)"/i);

			my $rows = '';
			if ($hash->{'title_textarea_rows'}) {
				$rows = ' rows=' . $hash->{'title_textarea_rows'} . ' ';
			}

			$input =~ s/input/textarea/i;
			$input =~ s/\/?>$/$rows><\$mt:var name="title" escape="html"\$><\/textarea>/i;
			$$tmpl =~ s/(<input(.(?!\/>))*?id="title"(.(?!\/>))*?.\/>)/$input/i;
		}
	}

	if ($hash->{'hide_body'}) {
		$style .= <<__EOH__;
#editor, #editor-content {
	position: absolute;
	z-index: -1;
}
#convert_breaks {
	display: none;
}
__EOH__
	}
	else {
		if (my $label = $hash->{'body_label'}) {
			$$tmpl =~ s/<__trans phrase="Body">/$label/g;
		}

		if ($hash->{'hide_extended'}) {
			$$tmpl =~ s/(<div[^>]*)(mt:tab="extended"(.|\r|\n)*?<\/div>)/$1 style="display: none" $2/si;
		}
		elsif (my $label = $hash->{'extended_label'}) {
			$$tmpl =~ s/<__trans phrase="Extended">/$label/g;
		}
	}

	if (my $label = $hash->{'excerpt_label'}) {
		$$tmpl =~ s/<__trans phrase="Excerpt">/$label/g;
	}

	if (my $label = $hash->{'categories_label'}) {
		$$tmpl =~ s/<__trans phrase="Categories">/$label/g;
	}

	{
		my $height = $hash->{'category_selector_height'};
		$height =~ s/^\s*|\s*$//g;
		if ($height) {
			if ($height =~ m/^\d+$/) {
				$height .= 'px';
			}
			$style .= '.category-selector-list { height: ' . $height . ';}';
		}
	}

	if ($style) {
		$style = <<__EOH__;
<style type="text/css">
$style
</style>
__EOH__

		#$$tmpl .= $style;
		my $replace = '<mt:?include[^>]*name="include/footer.tmpl"[^>]*>';
		$$tmpl =~ s#$replace#$style$&#i;
	}
}

1;
