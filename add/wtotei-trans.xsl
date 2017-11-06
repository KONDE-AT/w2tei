<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:hab="http://diglib.hab.de"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="3.0">
	<!-- neu 2016-07-28 Dario Kampkaspar (DK) – kampkaspar@hab.de -->
	
	<xsl:include href="ks-common.xsl"/>
	
	<xsl:output indent="yes"/>
	
	<xsl:template match="w:body">
		<xsl:apply-templates select="w:p[wdb:is(., 'berschrift1')]/following-sibling::w:p[not(descendant::w:t)]"/>
	</xsl:template>
	
	<!-- Paragraphen -->
	<xsl:template match="w:p[not(descendant::w:t)]">
		<xsl:variable name="myId" select="generate-id()"/>
		<div>
			<xsl:apply-templates select="following-sibling::w:p[hab:div(.)
				and generate-id(preceding-sibling::w:p[not(descendant::w:t)][1]) = $myId]" />
		</div>
	</xsl:template>
	
	<xsl:template match="w:p[wdb:is(., 'berschrift1')]" />
	
	<xsl:template match="w:p[hab:div(.)]">
		<xsl:variable name="myId" select="generate-id()"/>
		<p>
			<xsl:apply-templates select="preceding-sibling::w:p[descendant::w:t and not(hab:div(.))
				and generate-id(following-sibling::w:p[hab:div(.)][1]) = $myId]" />
			<xsl:text>
               </xsl:text>
			<lb/>
			<xsl:apply-templates select="." mode="pb"/>
		</p>
	</xsl:template>
	
	<xsl:template match="w:p[descendant::w:t and not(hab:isStruct(.))]">
		<xsl:if test="not(matches(wdb:string(.), '^\[.+?\]$'))">
			<xsl:text>
               </xsl:text>
			<lb/>
		</xsl:if>
		<xsl:apply-templates select="." mode="pb"/>
	</xsl:template>
	
	<xsl:template match="w:p" mode="pb">
		<xsl:variable name="temp">
			<xsl:apply-templates select="w:r"/>
		</xsl:variable>
		<xsl:for-each select="$temp/node()">
			<xsl:choose>
				<xsl:when test="self::text()">
					<xsl:analyze-string select="." regex="(\[.+?\])">
						<xsl:matching-substring>
							<xsl:text>
               </xsl:text>
							<pb n="{regex-group(1)}" />
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<xsl:value-of select="."/>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<!-- Ende Paragraphen -->
	
	<!-- kritische Anmerkungen -->
	<xsl:template match="w:r[descendant::w:footnoteReference]">
		<note type="crit_app"></note>
	</xsl:template>
	<!-- ENDE kritische Anmerkungen -->
		
	<!-- Funktionen -->
	<xsl:function name="hab:div" as="xs:boolean">
		<xsl:param name="context"/>
		<xsl:sequence select="if($context//w:sym/@w:char='F05E') then true() else false()"/>
	</xsl:function>
	
	<xsl:function name="hab:isStruct" as="xs:boolean">
		<xsl:param name="context" />
		<xsl:sequence select="hab:div($context) or wdb:is($context, 'KSEE-Titel')
			or wdb:is($context, 'berschrift1')"></xsl:sequence>
	</xsl:function>
</xsl:stylesheet>
