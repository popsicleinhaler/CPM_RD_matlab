function fn=mk_fun(script,manual_deps, override)
if nargin<2
    manual_deps={};
end
if nargin<3
    override={};
end
[str,deps] = inline_script(script, manual_deps, override);



suffix='_fun';
maxwidth=80;

header='function ';
line_length=strlength(header);
if ~isempty(deps)
    header = [header '['];
    for d=deps
        d=char(d);
        if line_length+length(d)+1<=maxwidth
            header=[ header d ','];
            line_length=line_length+strlength(d)+1;
        else
            header=[header '...' newline d ','];
            line_length=strlength(d)+1;
        end
    end
    
    header=[header(1:end-1) '] = '];
    line_length=line_length+3;
end

add=[script suffix '('];

if line_length+length(add)<=maxwidth+3
    header=[header add];
    line_length=line_length+strlength(add);
else
    header=[header '...' newline add];
    line_length=strlength(add);
end
if ~isempty(deps)
    for d=deps
        d=char(d);
        if line_length+length(d)+1<=maxwidth+3
            header=[header d ','];
            line_length=line_length+strlength(d)+1;
        else
            header=[ header '...' newline d ','];
            line_length=strlength(d)+1;
        end
    end
    header= header(1:end-1);
end
header = [header ')' newline];

fn=[char(script) suffix '.m'];
dlmwrite(fn, [header str newline 'end' ],'delimiter', '');

% fid = fopen(fn,'w');
% fprintf(fid, "%s", [header str newline 'end']);
% fclose(fid); 

end

