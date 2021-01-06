<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:wt="https://github.com/dariok/w2tei"
  xmlns:xstring = "https://github.com/dariok/XStringUtils"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" omit-xml-declaration="1" />
  
  <xsl:include href="string-pack.xsl"/>
  <xsl:include href="word-pack.xsl"/>
  
  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="w:document">
    <TEI>
      <teiHeader>
        <fileDesc>
          <sourceDesc>
            <p>Created from a MS Word file by <ref target="https://github.com/dariok/w2tei">W2TEI</ref>:
              <date when="{current-dateTime()}" type="created" /></p>
          </sourceDesc>
        </fileDesc>
      </teiHeader>
      <text>
        <body>
          <xsl:apply-templates select="w:body"/>
        </body>
        <back>
          <xsl:apply-templates select="//w:endnotes" />
        </back>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template match="w:body">
    <xsl:for-each-group select="w:p | w:tbl"
      group-starting-with="w:p[not(descendant::w:t or descendant::w:sym)]">
      <!--<xsl:text>
      </xsl:text>-->
      <div>
        <xsl:apply-templates select="current-group()" />
      </div>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="w:p[not(descendant::w:t or descendant::w:sym or ancestor::w:tbl)]" />
  <xsl:template match="w:p">
    <p>
      <xsl:apply-templates select="*" />
    </p>
  </xsl:template>
  <xsl:template match="w:comment/w:p">
    <note>
      <xsl:apply-templates select="*"/>
    </note>
  </xsl:template>
  <xsl:template match="w:p[descendant::w:numPr and not(ancestor::w:tc)]">
    <xsl:variable name="level" select="descendant::w:ilvl/@w:val" />
    <xsl:variable name="numId" select="descendant::w:numId/@w:val" />
    <!-- TODO this should be expanded later -->
    <xsl:variable name="label" select="//w:abstractNum[@w:abstractNumId eq $numId]/w:lvl[@w:ilvl eq $level]/w:lvlText/@w:val"/>
    
    <label>
      <xsl:value-of select="$label" />
    </label>
    <item level="{$level}">
      <xsl:apply-templates select="w:r" />
    </item>
  </xsl:template>
  
  <xsl:template match="w:pPr">
    <xsl:apply-templates select="w:pStyle" />
    <xsl:apply-templates select="w:rPr" />
  </xsl:template>
  
  <xsl:template match="w:r[not(*) or (w:rPr and not(w:rPr/following-sibling::*))]" />
  
  <xsl:template match="w:r">
    <ab>
      <xsl:sequence select="w:t/@xml:space" />
      <xsl:apply-templates select="w:rPr" />
      <xsl:apply-templates select="w:t | w:sym | w:tab | w:br" />
    </ab>
  </xsl:template>
  
  <xsl:template match="w:pStyle | w:rStyle">
    <xsl:attribute name="rendition" select="@w:val" />
  </xsl:template>
  
  <xsl:template match="w:rPr[*]" as="attribute()*">
    <xsl:apply-templates select="w:rStyle" />
    <xsl:if test="*[not(self::w:rStyle)]">
      <xsl:attribute name="style">
        <xsl:apply-templates select="*[not(self::w:rStyle)]" />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  <xsl:template match="w:rPr/*[not(self::w:rStyle)]">
    <xsl:value-of select="local-name()"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="translate((@w:val | @w:ascii)[1], ';', ',')" />
    <xsl:if test="following-sibling::*">
      <xsl:text>; </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="w:sym">
    <xsl:value-of select="codepoints-to-string(wt:hexToDec(@w:char))" />
  </xsl:template>
  
  <xsl:template match="w:r[w:fldChar/@w:fldCharType = ('separate','end')]" />
  <xsl:template match="w:r[w:fldChar/@w:fldCharType = 'begin']">
    <xsl:choose>
      <xsl:when test="contains(following-sibling::w:r[1]/w:instrText, 'HYPERLINK')">
        <ref>
          <xsl:attribute name="target">
            <xsl:variable name="target" select="substring(following-sibling::w:r[1]/w:instrText, 13)" />
            <xsl:value-of select="normalize-space(substring($target, 1, string-length($target) - 2))"/>
          </xsl:attribute>
          <xsl:apply-templates select="(following-sibling::w:r[w:fldChar][1]/following-sibling::*
            intersect following-sibling::w:r[w:fldChar][2]/preceding-sibling::*)/*" />
        </ref>
      </xsl:when>
      <xsl:otherwise>
        <field>
          <xsl:attribute name="function"
            select="string-join(following-sibling::w:r
            [not(preceding-sibling::w:r[w:fldChar[@w:fldCharType = 'separate']])]/w:instrText, '')"/>
          <xsl:apply-templates select="(following-sibling::w:r[w:fldChar][1]/following-sibling::*
            intersect following-sibling::w:r[w:fldChar][2]/preceding-sibling::*)/*" />
        </field>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="w:r[(w:t or w:sym) and preceding-sibling::w:r[w:fldChar][1][w:fldChar/@w:fldCharType = 'separate']
    and following-sibling::w:r[w:fldChar][1][w:fldChar/@w:fldCharType = 'end']]" priority="0.75"/>
  <xsl:template match="w:r[w:instrText]" />
  
  <xsl:template match="w:hyperlink">
    <xsl:variable name="content">
      <xsl:apply-templates select="w:r" />
    </xsl:variable>
    <xsl:variable name="id" select="@r:id"/>
    
    <ref>
      <xsl:attribute name="target">
        <xsl:variable name="rel" select="//*:Relationship[@Id = $id and @TargetMode eq 'External']/@Target"/>
        
        <xsl:choose>
          <xsl:when test="$rel">
            <xsl:value-of select="$rel"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$content"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      
      <xsl:sequence select="$content/tei:ab/@*" />
      <xsl:sequence select="$content/tei:ab/node()" />
    </ref>
  </xsl:template>
  
  <xsl:template match="w:r[w:footnoteReference]">
    <xsl:variable name="id" select="w:footnoteReference/@w:id"/>
    <xsl:variable name="note" select="//w:footnote[@w:id = $id]"/>
    <note type="footnote" xml:id="n{$id}">
      <xsl:apply-templates select="$note/w:p" />
    </note>
  </xsl:template>
  <xsl:template match="w:r[w:footnoteRef]" />
  
  <xsl:template match="w:r[w:endnoteReference]">
    <xsl:variable name="id" select="w:endnoteReference/@w:id"/>
    <xsl:variable name="note" select="//w:endnote[@w:id = $id]"/>
    <ptr type="endnote" ref="#e{$id}">
      <xsl:apply-templates select="$note//w:pStyle" />
    </ptr>
  </xsl:template>
  <xsl:template match="w:r[w:endnoteRef]" />
  <xsl:template match="w:endnotes">
    <xsl:apply-templates select="w:endnote[@w:id &gt; 0]" />
  </xsl:template>
  <xsl:template match="w:endnote">
    <note type="endnote" xml:id="e{@w:id}">
      <xsl:apply-templates select="w:p" />
    </note>
  </xsl:template>
  
  <xsl:template match="w:tab">
    <space width="tab" />
  </xsl:template>
  
  <xsl:template match="w:commentRangeEnd"/>
  <xsl:template match="w:commentRangeStart">
    <ptr type="comment" xml:id="c{@w:id}" />
  </xsl:template>
  <xsl:template match="w:r[w:commentReference]">
    <xsl:variable name="cID" select="w:commentReference/@w:id"/>
    <xsl:variable name="comment" select="//w:comment[@w:id = $cID]" />
    <note type="comment" from="#c{$cID}">
      <xsl:apply-templates select="$comment/w:p" />
    </note>
  </xsl:template>
  <xsl:template match="w:r[w:annotationRef]" />
  
  <!-- Tables -->
  <xsl:template match="w:tbl">
    <table cols="{count(w:tblGrid/w:gridCol)}">
      <xsl:apply-templates select="w:tr" />
    </table>
  </xsl:template>
  <xsl:template match="w:tr">
    <row>
      <xsl:apply-templates select="w:tc" />
    </row>
  </xsl:template>
  <xsl:template match="w:tc">
    <cell>
      <xsl:if test="w:tcPr/w:gridSpan">
        <xsl:attribute name="cols" select="w:tcPr/w:gridSpan/@w:val" />
      </xsl:if>
      <xsl:apply-templates select="w:p" />
    </cell>
  </xsl:template>
  <xsl:template match="w:tc/w:p">
    <xsl:if test="preceding-sibling::w:p">
      <lb />
    </xsl:if>
    <xsl:apply-templates select="w:r" />
  </xsl:template>
  
  <xsl:template match="w:bookmarkStart[@name = '_GoBack']" />
  <xsl:template match="w:bookmarkStart">
    <anchor type="bookmarkStart" xml:id="{@w:name}" /> 
  </xsl:template>
  <xsl:template match="w:bookmarkEnd">
    <xsl:variable name="target" select="@w:id" />
    <anchor type="bookmarkEnd" ref="#{preceding-sibling::w:bookmarkStart[@w:id = $target]/@w:name}" />
  </xsl:template>
  
  <xsl:template match="w:br">
    <lb />
  </xsl:template>
  
  <xsl:template match="pkg:part[not(@pkg:name='/word/document.xml')]" />
  
</xsl:stylesheet>