<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:variable name="bibliography" select="doc('http://dev2.hab.de/edoc/data/ed000216/register/kgk_bibliography.xml')" />
  <xsl:variable name="personenregister" select="doc('http://dev2.hab.de/edoc/data/ed000216/register/kgk_personenregister.xml')" />
  <xsl:variable name="ortsregister" select="doc('http://dev2.hab.de/edoc/data/ed000216/register/kgk_ortsregister.xml')" />
  
  <xsl:template match="tei:bibl">
    <rs type="bibl">
      <xsl:variable name="self" select="normalize-space()" />
      <xsl:variable name="entry" select="$bibliography//tei:bibl[starts-with($self, normalize-space(tei:abbr))]"/>
      <xsl:choose>
        <xsl:when test="count($entry) > 0">
          <xsl:attribute name="ref">
            <xsl:value-of select="'#'||$entry[1]/@xml:id"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>TODO ref eintragen!</xsl:comment>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="start">
        <xsl:value-of select="substring-after(text()[1], normalize-space($entry[1]/tei:abbr))"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="starts-with($start, ' ')">
          <xsl:value-of select="' '||normalize-space($start)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($start)"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="string-length($start) = 0">
          <xsl:sequence select="node()[not(position() = 1 or position()=last() or self::tei:hi[@rend = 'super'])]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="node()[not(position() = 1 or position()=last())]" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="count(node()) = 1" />
        <xsl:when test="node()[last()][self::text()]">
          <xsl:variable name="text" select="text()[last()]"/>
          <xsl:choose>
            <xsl:when test="starts-with($text, ' ')">
              <xsl:value-of select="' '||normalize-space($text)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space($text)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="node()[last()]" />
        </xsl:otherwise>
      </xsl:choose>
    </rs>
  </xsl:template>
  
  <xsl:template match="tei:rs[@type = 'person']">
    <xsl:call-template name="rsPerson" />
  </xsl:template>
  
  <xsl:template match="tei:rs[@type = 'place']">
    <xsl:call-template name="rsPlace" />
  </xsl:template>
  
  <xsl:template name="rsPerson">
    <rs type="person">
      <xsl:variable name="self" select="string-join(analyze-string(normalize-space(), '''')//*:non-match, '')" />
      <xsl:variable name="entry" select="$personenregister//tei:person[tei:persName[normalize-space() = $self]]"/>
      <xsl:choose>
        <xsl:when test="count($entry) > 0">
          <xsl:attribute name="ref">
            <xsl:value-of select="'#'||$entry[1]/@xml:id"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>TODO ref eintragen!</xsl:comment>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:sequence select="node()[not(self::comment())]" />
    </rs>
  </xsl:template>
  
  <xsl:template name="rsPlace">
    <rs type="place">
      <xsl:variable name="self" select="string-join(analyze-string(normalize-space(), '''')//*:non-match, '')" />
      <xsl:variable name="entry" select="$ortsregister//tei:place[descendant::tei:settlement[normalize-space() = $self]]"/>
      <xsl:choose>
        <xsl:when test="count($entry) > 0">
          <xsl:attribute name="ref">
            <xsl:value-of select="'#'||$entry[1]/@xml:id"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>TODO ref eintragen!</xsl:comment>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:sequence select="node()[not(self::comment())]" />
    </rs>
  </xsl:template>
</xsl:stylesheet>