﻿:Namespace HTMLInput

    ⎕IO ⎕ML←1 0
    ⎕FX 'r←CRLF' 'r←⎕UCS 13 10' ⍝ So it will be :Included
    enlist←{⎕ML←2 ⋄ ∊⍵} ⍝ APL2 enlist
    eis←{2>|≡⍵:,⊂⍵ ⋄ ⍵} ⍝ Enclose if simple
    ine←{0∊⍴⍺:'' ⋄ ⍵} ⍝ if not empty
    ischar←{0 2∊⍨10|⎕DR⍵}
    quote←{'"',⍵,'"'}

    ∇ r←atts Enclose innerhtml;i
    ⍝ Put an HTML tag around some HTML
      :If 1<|≡innerhtml ⋄ innerhtml←CRLF,enlist innerhtml,¨⊂CRLF ⋄ :EndIf
      i←¯1+(atts←,atts)⍳' '
      r←'<',atts,'>',innerhtml,'</',(i↑atts),'>',CRLF
    ∇

    ∇ r←Tag tag
    ⍝ Make a  self-closing tag
      r←'<',tag,' />',CRLF
    ∇

      Attrs←{
      ⍝ format name/value pairs as tag attributes
      ⍝  ⍵ - name/value pairs, valid forms:
      ⍝  'name="value"'
      ⍝  [n,2⍴] 'name1' 'value1' ['name2' 'value2'...]
      ⍝ ('name1' 'value1') [('name2' 'value2')]
          0∊⍴⍵:''
          {
              enlist{(×⍴⍺)/' ',⍺,(×⍴⍵)/'=',quote ⍵}/,∘⍕¨⊃⍵
          }_pifn¨,2 _box _pifn{
              1=|≡⍵:⍵
              2=|≡⍵:{1=⍴⍴⍵:(⌽2,0.5×⍴⍵)⍴⍵ ⋄ ⍵}⍵
              ↑⍵}⍵
      }

      Styles←{
      ⍝ format name/value pairs as CSS style attributes
      ⍝  ⍵ - name/value pairs, valid forms:
      ⍝  'name: value'
      ⍝  [n,2⍴] 'name1' 'value1' ['name2' 'value2'...]
      ⍝ ('name1' 'value1') [('name2' 'value2')]
          0∊⍴⍵:''
          {'{',({';'=¯1↑⍵:⍵ ⋄ ⍵,';'}⍵),' }'}{
              enlist{(×⍴⍺)/' ',⍺,(×⍴⍵)/': ',⍵,';'}/,∘⍕¨⊃⍵
          }_pifn¨,2 _box _pifn{
              1=|≡⍵:⍵
              2=|≡⍵:{1=⍴⍴⍵:(⌽2,0.5×⍴⍵)⍴⍵ ⋄ ⍵}⍵
              ↑⍵}⍵
      }

    _box←{⍺←1 ⋄ (⊂⍣(⍺=|≡⍵))⍵}
    _pifn←{({⍵''}⍣(1=|≡⍵))⍵}

    ∇ html←TextToHTML html;mask;CR
    ⍝ Add/insert <br/>, replaces CR with <br/>,CR
      :If ~0∊⍴html
          :If ∨/mask←html=CR←''⍴CRLF
              (mask/html)←⊂'<br/>',CR
              html←enlist html
          :EndIf
          html,←(~∨/¯2↑mask)/'<br/>',CRLF
      :EndIf
    ∇

    ∇ html←{fontsize}APLToHTML APL
    ⍝ returns APL code formatted for HTML
      fontsize←{6::'' ⋄ ';fontsize:',⍎⍵}'fontsize'
      :If 1<|≡APL ⋄ APL←enlist,∘CRLF¨APL ⋄ :EndIf
      :Trap 0
          html←3↓¯4↓'whitespace' 'preserve'⎕XML 1 3⍴0 'x'APL
      :Else
          html←APL
      :EndTrap
      html←('pre style="font-family:APL385 Unicode',fontsize,'"')Enclose CRLF,⍨html
    ∇

    ∇ html←{id}Anchor pars;href;title;target;other;content
    ⍝ Builds an anchor <a> tag
    ⍝ pars: content {href} {title} {target} {other_attrs}
      :If 0=⎕NC'id' ⋄ id←'' ⋄ :EndIf
      pars←eis pars
      content href title target other←5↑pars,(⍴pars)↓'' '' '' '' ''
      html←('a',(Attrs'id' 'href' 'title' 'target'{(⍵ ine ⍺)⍵}¨id href title target),Attrs other)Enclose content
    ∇

    ∇ html←{n}BRA html
    ⍝ (BReak After) Add n <br/>'s after html
      :If 0=⎕NC'n' ⋄ n←1 ⋄ :EndIf
      html,←(n{(⍺×⍴⍵)⍴⍵}'<br/>'),CRLF
    ∇

    ∇ html←{n}BR html
    ⍝ (BReak) Add n <br/>'s before html
      :If 0=⎕NC'n' ⋄ n←1 ⋄ :EndIf
      html←(n{(⍺×⍴⍵)⍴⍵}'<br/>'),CRLF,html
    ∇

    ∇ html←{n}SP html
    ⍝ (SPace) Add n non-breaking spaces &nbsp; before html
      :If 0=⎕NC'n' ⋄ n←1 ⋄ :EndIf
      html←(n{(⍺×⍴⍵)⍴⍵}'&nbsp;'),html
    ∇

    ∇ r←{src}JS script
    ⍝ Javascript
    ⍝ script: javascript script if no src or filename if src=1
      :If 0≠⎕NC'src' ⋄ r←('script type="text/javascript" src=',quote src)Enclose''
      :Else ⋄ r←'script type="text/javascript"'Enclose script ine CRLF,'/* <![CDATA[ */',CRLF,script,CRLF,'/* ]]> */',CRLF
      :EndIf
    ∇

    ∇ r←{name}DropDown pars;values;display;gv;mask;n
    ⍝ par - items selected_value(s) attributes sort
    ⍝ if items is 2 column matrix, [;1] is values, [;2] is display
      :If 0=⎕NC'name' ⋄ name←'' ⋄ :EndIf
      :If 2=⍴⍴pars ⋄ pars←,⊂pars ⋄ :EndIf
      pars←pars,(⍴pars)↓('Item1' 'Item2')'Item1' '' 0
      :If ~ischar 1⊃pars ⋄ pars[1]←⊂⍕¨1⊃pars ⋄ :EndIf
      :If 1=⍴⍴1⊃pars ⋄ values display←pars[1]
      :Else ⋄ values display←↓[1]1⊃pars
      :EndIf
      mask←values∊eis 2⊃pars
      :If 4⊃pars ⋄ gv←⍒mask ⋄ values←values[gv] ⋄ display←display[gv] ⋄ mask←mask[gv] ⋄ :EndIf ⍝ Sort selected items first
      r←'<select ',(3⊃pars),(name ine' id=',n,' name=',n←quote name),'>',CRLF
      r,←enlist(mask{'<option value="',(⍕⍵),'"',(⍺/' selected="selected"'),'>'}¨values),¨display,¨⊂'</option>',CRLF
      r,←'</select>',CRLF
    ∇

    ∇ r←{atts}(method Form)innerhtml
      :If 9=⎕NC'atts' ⋄ atts←'action="',atts.Page,'"' ⍝ MildPage calling
      :ElseIf 0=⎕NC'atts' ⋄ atts←'' ⋄ :EndIf
      atts,←' method="',method,'"'
      atts,←('post'≡#.Strings.lc method)/' enctype="multipart/form-data"'
      r←('form ',atts)Enclose innerhtml
    ∇

    ∇ r←{name}Edit pars
    ⍝ pars: [value [size [attributes]]]
      :If 0=⎕NC'name' ⋄ name←''
      :Else ⋄ name←enlist(,∘('="',name,'"'))¨' id' ' name'
      :EndIf
      pars←,eis pars
      pars←pars,(⍴pars)↓''⍬''
      r←Tag'input ',(3⊃pars),' type="text" size="',(⍕2⊃pars),'" value="',(1⊃pars),'"',name
    ∇


    ∇ r←{name}Submit pars
    ⍝ pars: value [attributes]
      :If 0=⎕NC'name' ⋄ name←''
      :Else ⋄ name←enlist(,∘('="',name,'"'))¨' id' ' name'
      :EndIf
      pars←,eis pars
      pars←pars,(⍴pars)↓'Submit' '' ''
      r←Tag'input type="submit" ',(2⊃pars),' value="',(1⊃pars),'"',name
    ∇

    ∇ r←{name}Button pars
    ⍝ pars: value [attributes]
      :If 0=⎕NC'name' ⋄ name←''
      :Else ⋄ name←enlist(,∘('="',name,'"'))¨' id' ' name'
      :EndIf
      pars←,eis pars
      pars←pars,(⍴pars)↓'Button' ''
      r←Tag'input type="button" ',(2⊃pars),' value="',(1⊃pars),'"',name
    ∇

    ∇ r←{name}File pars
    ⍝ pars: [value [size [attributes]]
      :If 0=⎕NC'name' ⋄ name←''
      :Else ⋄ name←enlist(,∘('="',name,'"'))¨' id' ' name'
      :EndIf
      pars←,eis pars
      pars←pars,(⍴pars)↓''⍬''
      r←Tag'input ',(3⊃pars),' type="file" size="',(⍕2⊃pars),'" value="',(1⊃pars),'"',name
    ∇

    ∇ r←{name}Hidden pars
    ⍝ pars: value [attributes]
      :If 0=⎕NC'name' ⋄ name←''
      :Else ⋄ name←enlist(,∘('="',name,'"'))¨' id' ' name'
      :EndIf
      pars←,eis pars
      pars←pars,(⍴pars)↓'' ''
      r←Tag'input ',(2⊃pars),' type="hidden" value="',(1⊃pars),'"',name
    ∇

    ∇ r←{name}Password pars
    ⍝ pars: size [value [attributes]]
      :If 0=⎕NC'name' ⋄ name←''
      :Else ⋄ name←enlist(,∘('="',name,'"'))¨' id' ' name'
      :EndIf
      pars←pars,(⍴pars)↓''⍬''
      r←Tag'input ',(3⊃pars),' type="password" size="',(⍕2⊃pars),'" value="',(1⊃pars),'"',name
    ∇

    ∇ r←{name}CheckBox pars
    ⍝ pars: checked [attributes]
      :If 0=⎕NC'name' ⋄ name←''
      :Else ⋄ name←enlist(,∘('="',name,'"'))¨' id' ' name'
      :EndIf
      pars←eis pars
      pars←pars,(⍴pars)↓0 ''
      r←Tag'input ',(2⊃pars),' type="checkbox"',name,(0≠1⊃pars)/' checked="checked"'
    ∇

    ∇ r←{name}RadioButton pars
    ⍝ pars: checked [value [attributes]]
      :If 0=⎕NC'name' ⋄ name←''
      :Else ⋄ name←enlist(,∘('="',name,'"'))¨' id' ' name'
      :EndIf
      pars←eis pars
      pars←pars,(⍴,pars)↓0 name''
      r←Tag'input ',(3⊃pars),' type="radio" value="',(2⊃pars),'"',name,(0≠1⊃pars)/' checked="checked"'
    ∇

    ∇ r←{name}Table pars;x;data;atts;tdc;tda;thc;tha;hdrrows;z;mask;cellids
    ⍝ pars: data table_atts cell_attribs header_attribs header_rows cell-ids?
      :If 0=⎕NC'name' ⋄ name←'' ⋄ :EndIf
      :If 2=⍴⍴pars ⋄ pars←,⊂pars ⋄ :EndIf ⍝ Matrix of data only
      pars←pars,(⍴,pars)↓(1 1⍴⊂'data')'' '' ''⍬ 0
      data atts tda tha hdrrows cellids←pars ⋄ hdrrows←,hdrrows
      data←((×/¯1↓⍴data),¯1↑⍴data)⍴data
      x←⍕¨data
      :If cellids ⍝ do we add cell ids?
          r←(' id="'∘,∘(,∘'">')¨{enlist'rc',¨⍕¨⍵}¨⍳⍴data),¨x,¨⊂'</td>'
      :Else
          r←'>',¨x,¨⊂'</td>'
      :EndIf
      :If (⍴tda)≡⍴data
          r←('<td'∘,¨tda ine¨' ',¨tda),¨r
      :Else
          r←('<td',tda ine' ',tda)∘,¨r
      :EndIf
      :If z←0≠⍴hdrrows ⋄ r[hdrrows;]←(⊂'<th',(tha ine' ',tha),'>'),¨x[hdrrows;],¨⊂'</th>' ⋄ :EndIf
      r←'<tr>'∘,¨(,/r),¨⊂'</tr>',CRLF
      :If z ⋄ mask←(⍴r)⍴1 ⋄ mask[hdrrows]←⊂0 1 0 ⋄ mask←enlist mask
          r←mask\r
          r[(~mask)/⍳⍴mask]←(2×⍴hdrrows)⍴'<thead>' '</thead>'
      :EndIf
      r←('table',(name ine' id="',name,'"'),(atts ine' ',atts))Enclose CRLF,(enlist r),CRLF
    ∇

    ∇ r←{name}List pars;items;ordered;t
    ⍝ pars: items [ordered? 0/1]
      :If 0=⎕NC'name' ⋄ name←'' ⋄ :EndIf
      :Select ≡pars
      :CaseList 1 ¯2 ⋄ ordered←¯1↑pars ⋄ items←eis ¯1↓pars
      :Case 2 ⋄ ordered←0 ⋄ items←pars
      :Else ⋄ (items ordered)←2↑pars,(⍴,pars)↓'' 0
      :EndSelect
      t←(1+ordered)⊃'ul' 'ol'
      r←(t,name ine' id=',quote name)Enclose enlist'li'∘Enclose¨items
    ∇

    ∇ r←{name}MultiEdit pars
    ⍝ pars: (rows cols) [values [attributes]]
      :If 0=⎕NC'name' ⋄ name←'' ⋄ :EndIf
      pars←pars,(⍴pars)↓(10 40)'' ''
      r←'textarea ',(3⊃pars),(name ine' id="',name,'" name="',name,'"'),' rows="',(⍕1 1⊃pars),'" cols="',(⍕1 2⊃pars),'"'
      r←r Enclose CRLF,(2⊃pars),CRLF
    ∇

      MakeStyle←{
          ⍺←''
          0∊⍴⍵:''
          (' ',⍨¯2↓enlist(eis ⍺),¨⊂', '),Styles ⍵
      }

    ∇ r←HtmlSafeText txt;i;m;u;ucs
    ⍝ make text HTML "safe"
      r←,⎕FMT txt
      i←'&<>"#'⍳r
      i-←(i=1)∧1↓(i=5),0 ⍝ mark & that aren't &#
      m←i∊⍳4
      u←127<ucs←⎕UCS r
      (m/r)←('&amp;' '&lt;' '&gt;' '&quot;')[m/i]
      (u/r)←(~∘' ')¨↓'G<&#ZZZ9;>'⎕FMT u/ucs
      r←enlist r
    ∇

:EndNamespace