<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:hab="http://diglib.hab.de"
    xmlns:wdb="https://github.com/dariok/wdbplus"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="3.0">
    
    <xsl:include href="styles-inc.xsl"/>
    
<!--    <xsl:output indent="yes"/>-->
    
    <xsl:template match="tei:*">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="w:footnotes | w:numbering | w:comments" />
    
    <xsl:template match="w:p[not(w:r)]" />
    
    <!-- Marginalie -->
    <xsl:template match="w:p[wdb:is(., 'KSMarginalie', 'p')]">
        <note place="margin"><xsl:apply-templates select="w:r" /></note>
    </xsl:template>
    
<!--    <xsl:template match="w:p[descendant::w:numPr][position() &gt; 1]"/>-->
    <xsl:template match="tei:p[descendant::w:numPr]">
        <list>
            <xsl:apply-templates select="w:p[descendant::w:numPr]"/>
        </list>
    </xsl:template>
    
    <!--<xsl:template match="tei:p">
        <xsl:text>
    </xsl:text>
        <p>
            <xsl:apply-templates select="@*|node()" />
        </p>
    </xsl:template>-->
    
    <xsl:template match="w:p[descendant::w:numPr]">
        <xsl:variable name="numId" select="descendant::w:numPr/w:numId/@w:val"/>
        <xsl:variable name="ilvl" select="descendant::w:numPr/w:ilvl/@w:val"/>
        <xsl:variable name="num" select="//w:numbering/w:num[@w:numId = $numId]/w:abstractNumId/@w:val"/>
        <xsl:variable name="style" select="//w:numbering/w:abstractNum[@w:abstractNumId = $num]/w:lvl[@w:ilvl = $ilvl]/w:numFmt/@w:val" />
        <xsl:variable name="myID" select="generate-id()" />
        
        <label>
            <xsl:choose>
                <xsl:when test="wdb:is(w:r[1], 'KSkorrigierteThesennummer', 'r')">
                    <app>
                        <lem>
                            <xsl:choose>
                                <xsl:when test="$style = 'upperRoman'">
                                    <xsl:number count="w:p[descendant::w:numPr]" format="I" />
                                </xsl:when>
                                <xsl:when test="$style = 'lowerRoman'">
                                    <xsl:number count="w:p[descendant::w:numPr]" format="i" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:number count="w:p[descendant::w:numPr]" />
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>.</xsl:text>
                        </lem>
                        <rdg>
                            <xsl:apply-templates select="w:r[1]/w:t"/>
                        </rdg>
                    </app>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$style = 'upperRoman'">
                            <xsl:number count="w:p[descendant::w:numPr]" format="I" />
                        </xsl:when>
                        <xsl:when test="$style = 'lowerRoman'">
                            <xsl:number count="w:p[descendant::w:numPr]" format="i" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:number count="w:p[descendant::w:numPr]" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        	<xsl:if test="w:r[1]/w:footnoteReference and wdb:starts(., ' ')">
        		<xsl:apply-templates select="w:r[1]"/>
        	</xsl:if>
        </label>
        <item>
        	<xsl:choose>
        		<xsl:when test="w:r[1]/w:footnoteReference">
        			<xsl:apply-templates select="w:r[position() &gt; 1] | following-sibling::w:p[not(descendant::w:numPr)
        				and $myID = generate-id(preceding-sibling::w:p[descendant::w:numPr][1])]" />
        		</xsl:when>
        		<xsl:otherwise>
        			<xsl:apply-templates select="w:r | following-sibling::w:p[not(descendant::w:numPr)
        				and $myID = generate-id(preceding-sibling::w:p[descendant::w:numPr][1])]" />
        		</xsl:otherwise>
        	</xsl:choose>
        </item>
    </xsl:template>
    <xsl:template match="w:r[wdb:is(., 'KSkorrigierteThesennummer', 'r')]" />
    
    <xsl:template match="w:p[w:r and not(wdb:is(., 'KSMarginalie', 'p') or descendant::w:numPr
        or ancestor::w:endnote or ancestor::w:footnote)]">
        <!--<xsl:param name="parind" select="xs:integer(0)"/>-->
        <xsl:variable name="parind" select="descendant::w:ind/@w:left"/>
        <xsl:variable name="relind">
            <xsl:choose>
                <xsl:when test="$parind castable as xs:integer and $parind > 0 and descendant::w:ind">
                    <xsl:value-of select="xs:integer(descendant::w:ind/@w:left) - xs:integer($parind)"/>
                </xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="temp">
            <xsl:apply-templates select="w:r | w:bookmarkStart"/>
        </xsl:variable>
        <xsl:variable name="content">
            <xsl:for-each select="$temp/node()">
                <xsl:choose>
                    <xsl:when test="self::text()">
                        <xsl:analyze-string select="." regex="(\[.+?\])">
                            <xsl:matching-substring>
                                <pb n="{regex-group(1)}" />
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:choose>
                                    <xsl:when test="ends-with(., '')">
                                        <xsl:value-of select="wdb:substring-before-if-ends(., '')"/>
                                    </xsl:when>
                                    <xsl:when test="ends-with(., '⏊')">
                                        <xsl:value-of select="wdb:substring-before-if-ends(., '⏊')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <lb />
        <xsl:choose>
            <xsl:when test="$relind castable as xs:integer and  $relind > 0">
                <ab style="centre">
                    <xsl:sequence select="$content"/>
                </ab>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$content" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Ende Paragraphen -->
    
    <!-- Verweise -->
    <xsl:template match="w:bookmarkStart">
        <xsl:if test="not(@w:name = '_GoBack')">
            <hab:bm name="{@w:name}"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="w:r[w:fldChar]">
        <xsl:if test="not(w:fldChar/@w:fldCharType='separate')">
            <hab:mark>
                <xsl:if test="w:fldChar/@w:fldCharType='begin'">
                    <xsl:attribute name="ref" select="normalize-space(following-sibling::w:r[1]/w:instrText)"/>
                </xsl:if>
            </hab:mark>
        </xsl:if>
    </xsl:template>
    
    <!-- EE-Verweis -->
    <xsl:template match="w:r[wdb:is(., 'KSEEVerweis', 'r')]">
        <ptr type="wdb">
            <xsl:choose>
                <xsl:when test="contains(., 'II')">
                    <xsl:comment> TODO verlinken</xsl:comment>
                    <xsl:apply-templates select="w:t" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:comment> TODO verlinken</xsl:comment>
                    <xsl:apply-templates select="w:t" />
                </xsl:otherwise>
            </xsl:choose>
        </ptr>
    </xsl:template>
    
    <!-- Langes Zitat bzw. Paraphrase -->
    <xsl:template match="w:r[wdb:isFirst(., 'KSQuote', 'r')]">
        <hab:para place="start"/>
    </xsl:template>
    <xsl:template match="w:r[wdb:is(., 'KSQuote', 'r') and following::w:r[1][not(wdb:is(., 'KSQuote', 'r'))]]">
        <hab:para place="end" />
    </xsl:template>
    
	<!-- kritische Anmerkungen -->
	<xsl:template match="w:r[descendant::w:footnoteReference
		and not(wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r'))]">
		<xsl:apply-templates select="w:footnoteReference" />
	</xsl:template>
	
    <xsl:template match="w:footnoteReference">
        <note type="crit_app">
            <xsl:variable name="wid" select="@w:id"/>
            <xsl:apply-templates select="//w:footnote[@w:id = $wid]/w:p/w:r" />
        </note>
    </xsl:template>
    
    <xsl:template match="w:r[wdb:isFirst(., 'KSkritischeAnmerkungbermehrereWrter', 'r')
        and following::w:r[1][wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')]]">
        <anchor type="crit_app" ref="s"/>
        <xsl:apply-templates select="w:t" />
    </xsl:template>
    <xsl:template match="w:r[wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r') and
        not(following::w:r[1][wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')])]">
        <xsl:if test="not(preceding::w:r[1][wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')])">
            <anchor type="crit_app" ref="s" />
        </xsl:if>
        <xsl:apply-templates select="w:t" />
        <anchor type="crit_app" ref="se" />
    </xsl:template>
    <!-- es kommen krit. oder Sachanmerkungen innerhalb dieses Teils vor -->
	<xsl:template match="w:r[not(wdb:isFirst(., 'KSkritischeAnmerkungbermehrereWrter', 'r'))
		and wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')
		and following::w:r[1][wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')]
		and preceding::w:r[1][wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')]]">
		<xsl:apply-templates select="w:t | w:footnoteReference | w:endnoteReference"/>
	</xsl:template>
    
    <xsl:template match="w:r[wdb:is(., 'KSKommentar', 'r') and not(descendant::w:i/@w:val='0')
        and not(descendant::w:vertAlign)]">
        <note type="comment">
            <xsl:apply-templates select="w:t"/>
        </note>
    </xsl:template>
    <xsl:template match="w:r[wdb:is(., 'KSKommentar', 'r') and not(descendant::w:i/@w:val='0')
        and descendant::w:vertAlign]">
        <hi>
            <xsl:attribute name="rend">
                <xsl:choose>
                    <xsl:when test="descendant::w:vertAlign/@w:val='subscript'">sub</xsl:when>
                    <xsl:otherwise>super</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="w:t"/>
        </hi>
    </xsl:template>
    <xsl:template match="w:r[wdb:is(., 'KSKommentar', 'r') and descendant::w:i/@w:val='0']">
         <note type="comment"><orig><xsl:apply-templates select="w:t"/></orig></note>
    </xsl:template>
    <!-- ENDE kritische Anmerkungen -->
    
    <!-- neu 2017-12-08 DK -->
    <xsl:template match="w:r[wdb:is(., 'KSBibelstelle', 'r')]">
        <xsl:choose>
            <xsl:when test="ends-with(w:t, 'Vg')">
                <ref type="biblical"><xsl:value-of select="substring-before(w:t, ' Vg')"/></ref> Vg
            </xsl:when>
            <xsl:otherwise>
                <ref type="biblical"><xsl:apply-templates select="w:t" /></ref>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="w:r[wdb:is(., 'KSAutorenstelle', 'r')]">
        <ref type="medieval">
            <xsl:attribute name="cRef">
                <xsl:value-of select="substring-before(w:t, ',')" />
                <xsl:text>!</xsl:text>
                <xsl:value-of select="normalize-space(substring-after(w:t, ','))" />
            </xsl:attribute>
            <xsl:comment>TODO: cRef prüfen!</xsl:comment>
            <xsl:apply-templates select="w:t" />
        </ref>
    </xsl:template>
    
    <!--<xsl:template match="w:r[not(w:rStyle or descendant::w:footnoteReference or descendant::w:endnoteReference or descendant::w:i)]">
        <xsl:apply-templates select="w:t" />
    </xsl:template>-->
    
    <xsl:template match="w:p[wdb:is(., 'KSlistWit', 'p')]">
        <xsl:variable name="text"><xsl:apply-templates select="w:r"/></xsl:variable>
        <xsl:variable name="value" select="wdb:substring-before-if-ends($text, '')"/>
        <witness><xsl:value-of select="$value"/></witness>
    </xsl:template>
    
    <xsl:template match="text() | @*">
        <xsl:copy>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>