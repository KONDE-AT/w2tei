<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:include href="../string-pack.xsl" />
	
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="tei:*">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="@* | node()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:choose>
			<xsl:when test="following-sibling::node()[1][self::tei:note[@type = 'crit_app']]">
				<xsl:variable name="last" select="tokenize(., ' ')[last()]"/>
				<xsl:variable name="front" select="wdb:substring-before-last(., ' ')" />
				<xsl:variable name="note" select="following-sibling::tei:note[1]"/>
				
				<xsl:value-of select="string-join($front, ' ')"/>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<!-- Phrasen in 128 -->
					<xsl:when test="$note/tei:hi[normalize-space() = 'vom Editor verbessert für' or
						normalize-space() = 'vom Editor verbessert aus' or normalize-space() = 'von Editor verbessert aus']">
						<choice>
							<sic><xsl:value-of select="normalize-space($note/tei:hi/following-sibling::text())"/></sic>
							<corr><xsl:value-of select="$last"/></corr>
						</choice>
					</xsl:when>
					<xsl:when test="$note/node()[1][self::text()]">
						<!-- TODO später für mehrere rdg anpassen -->
						<xsl:variable name="wit" select="normalize-space($note/tei:hi)"/>
						<app>
							<lem wit="#A"><xsl:value-of select="$last"/></lem>
							<rdg wit="#{$wit}"><xsl:value-of select="normalize-space($note/text()[1])"/></rdg>
						</app>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$last"/>
						<xsl:sequence select="$note"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:when test="matches(., '&lt;.+&gt;')">
				<xsl:analyze-string select="." regex="&lt;.+&gt;">
					<xsl:matching-substring>
						<supplied><xsl:value-of select="substring(substring-before(., '&gt;'), 2)"/></supplied>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:value-of select="."/>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:note[@type='crit_app']" />
	
	<xsl:template match="@*">
		<xsl:copy-of select="." />
	</xsl:template>
</xsl:stylesheet>