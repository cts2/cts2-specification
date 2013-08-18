<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="http://www.omg.org/spec/cts2/1.2/function"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="xml" omit-xml-declaration="yes" media-type="application/json" />
    
    <xsl:strip-space elements="*"/>
    
    <!-- Rule 1: Outermost node is an object -->
    <xsl:template match="/">
        <xsl:text>{ </xsl:text>
        <xsl:apply-templates/>
        <xsl:text> }</xsl:text>
    </xsl:template>
    
    <!-- Element Match -->
    <xsl:template match="*">
        <!-- add a comma when constructing a list or object member -->
        <xsl:if test="position() > 1">, </xsl:if>
        <xsl:choose>
            <xsl:when test="boolean(@_CDATA)">
                <!-- Rule 13: _CDATA attribute -->
                <xsl:call-template name="name"/>
                <!-- Rule 9: content explicitly tagged if mixed with attributes -->
                <xsl:if test="count(@*) > 1">
                    <xsl:text>{ </xsl:text>
                    <xsl:apply-templates select="@*[name() != '_CDATA']"/>
                    <xsl:text>, "content": </xsl:text>
                </xsl:if>
                <xsl:text>"</xsl:text>
                <!-- NOTE: this does not escape embedded characters. -->
                <xsl:copy-of select="node()"/>
                <xsl:text>"</xsl:text>
                <xsl:if test="count(@*) > 1">
                    <xsl:text> }</xsl:text>
                </xsl:if>
            </xsl:when>
 
            <xsl:when test="count(../*[name()=current()/name()]) = 1">
                <!-- Non-repeating element -->
                <xsl:call-template name="name"/>
                <xsl:choose>
                    <xsl:when test="count(*) + count(@*) > 0">
                        <!-- With at least one child element or attribute -->
                        <xsl:choose>
                            <xsl:when test="count(text()) = 1 and count(*)=0">
                                <!-- Only attributes and simple content - make into JSONObject -->
                                <xsl:text>{ </xsl:text>
                                <xsl:apply-templates select="text()|@*"/>
                                <xsl:text> }</xsl:text>
                            </xsl:when>
                            <xsl:when test="count(text()) > 0 and count(*) > 0">
                                <!-- Mixed mode - make into JSONArray named 'content' -->
                                <xsl:text>"content": [</xsl:text>
                                <xsl:apply-templates select="text()|*|@*"/>
                                <xsl:text>]</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Elements and attributes, no text.  Make into JSONObject -->
                                <xsl:text>{ </xsl:text>
                                <xsl:apply-templates select="*|@*"/>
                                <xsl:text> }</xsl:text></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="string-length(text()) > 0">
                        <!-- Only text.  Make into JSONMember -->
                        <xsl:apply-templates select="text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Nothing. Rule 5: Empty elements become an empty string -->
                        <xsl:text>""</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- Repeating element - make into a JSONArray -->
                <xsl:if test="count(preceding-sibling::node()[name()=current()/name()]) = 0">
                    <xsl:call-template name="name"/>
                    <xsl:text>[</xsl:text>
                </xsl:if>
                <xsl:if test="count(*) + count(@*) > 0">
                    <xsl:text>{ </xsl:text>
                </xsl:if>
                <xsl:apply-templates select="text()|*|@*"/>
                <xsl:if test="count(*) + count(@*) > 0">
                    <xsl:text> }</xsl:text>
                </xsl:if>
                <xsl:if test="count(following-sibling::node()[name()=current()/name()]) = 0">
                    <xsl:text>]</xsl:text>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@*">
        <!-- Attriutes are represented as JSONMember -->
        <xsl:if test="position() > 1">, </xsl:if>
        <xsl:call-template name="name"/>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
    </xsl:template>
    
    
    <xsl:template match="text()">
        <!-- Text is JSONValue if alone otherwise JSONMember with JSONString of "content" -->
        <xsl:if test="position() > 1">, </xsl:if>
        <xsl:if test="../@*">"content": </xsl:if>
        <xsl:value-of select="concat('&quot;', f:escape(.), '&quot;')"/>
    </xsl:template>
    
    <!-- Format a name, removing all namespaces except 'xsi' -->
    <xsl:template name="name">
        <xsl:text>"</xsl:text>
        <xsl:choose>
            <xsl:when test="namespace-uri()='http://www.w3.org/2001/XMLSchema-instance'">
                <xsl:value-of select="concat('xsi:',local-name())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="local-name()"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>": </xsl:text>
    </xsl:template>
    
    <!-- Escape text, replacing tabs, line feeds, carriage returns, back slashes and quotes -->
    <xsl:function name="f:escape">
        <xsl:param name="text"/>
        <xsl:value-of select="replace(
            replace(
            replace(
            replace(
            replace($text,'\\','\\\\'),
            '&quot;','\\&quot;'),
            '\r','\\r'),'\t','\\t'),
            '\n','\\n')"/>
    </xsl:function>
</xsl:stylesheet>