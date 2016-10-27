<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:functx="http://www.xsltfunctions.com/"
    xmlns:catxml="http://webi.provant.be/brocade/catalog/catxml.dtd"
    xmlns:OAI-PMH="http://www.openarchives.org/OAI/2.0/">
    <xsl:template match="/">
        <marc:collection xmlns:marc="http://www.loc.gov/MARC21/slim"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.loc.gov/MARC21/slim
            http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
            <xsl:apply-templates select="CATFILE/RECORD"> </xsl:apply-templates>
        </marc:collection>
    </xsl:template>
    <xsl:template match="RECORD">
        <marc:record>
            <marc:leader>00000nam a2200000 i 4500</marc:leader>
            <xsl:comment>Control Number</xsl:comment>
            <marc:controlfield tag="001">
                <xsl:value-of select="@cloi"/>
            </marc:controlfield>
            <!-- controlfield tag="003" organization identifier related to 001-tag> -->
            <xsl:comment>Control Number Identifier</xsl:comment>
            <marc:controlfield tag="003">provant.be</marc:controlfield>
            <!-- calculation of last modification date for controlfield 005
                Notatie: waarde van @md omzetten naar ISO datum/tijd
                codering $HOROLOG (iets MUMPS gerelateerd): 'md="59201,"' is gelijk aan '2003-01-31Z' 
                Formule: (md + 672413) / 365,2436724566 = YYYY,0000  >> geeft bij benadering juiste jaartal-->
            <xsl:variable name="JaarQuotient">
                <xsl:value-of
                    select="sum((number (substring-before(TSECTION/@md,',') ), 672413)) div 365.2436724566"
                />
            </xsl:variable>
            <!-- MaandQuotient wordt berekend op deel na decimaal van jaarquotient/12*10 en afronding-->
            <xsl:variable name="MaandQuotient">
                <xsl:value-of
                    select="(floor((number($JaarQuotient) - floor(number($JaarQuotient))) * 12 + 1))"
                />
            </xsl:variable>
            <!-- MaandQuotient2 wordt berekend door MaandQuotient1 indien nodig aan te vullen met voorloopnullen) -->
            <xsl:variable name="MaandQuotient2">
                <xsl:choose>
                    <xsl:when test="string-length($MaandQuotient) &lt; 2">
                        <xsl:value-of select="concat('0',$MaandQuotient)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$MaandQuotient"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- calculation of the creation date for control field 008 position 00-05 -->
            <xsl:variable name="JaarQuotientcd">
                <xsl:value-of
                    select="sum((number (substring-before(TSECTION/@cd,',') ), 672413)) div 365.2436724566"
                />
            </xsl:variable>
            <!-- MaandQuotientcd wordt berekend op deel na decimaal van jaarquotient/12*10 -->
            <xsl:variable name="MaandQuotientcd">
                <xsl:value-of
                    select="(floor((number($JaarQuotientcd) - floor(number($JaarQuotientcd))) * 12 + 1))"
                />
            </xsl:variable>
            <!-- MaandQuotient2cd wordt berekend door afgeronde MaandQuotient1 aan te vullen met voorlooptnullen) -->
            <xsl:variable name="MaandQuotient2cd">
                <xsl:choose>
                    <xsl:when test="string-length($MaandQuotientcd) &lt; 2">
                        <xsl:value-of select="concat('0',$MaandQuotientcd)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$MaandQuotientcd"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:comment>Date and Time of Latest Transaction, rounded to month</xsl:comment>
            <marc:controlfield tag="005">
                <xsl:value-of
                    select="concat(floor(number($JaarQuotient)),$MaandQuotient2,'01000000.0')"/>
            </marc:controlfield>
            <xsl:comment>Fixed-Length Data Elements</xsl:comment>
            <marc:controlfield tag="008">
                <xsl:value-of select="concat(substring($JaarQuotientcd,3,2),$MaandQuotient2cd,'01')"/>
                <!-- TODO nog nakijken, bevat fouten, maar wschlijk niet zo belangrijk -->
                <xsl:choose>
                    <xsl:when test="BSECTION/IM/JU/@ju1ty='s.a.'">b</xsl:when>
                    <xsl:when test="BSECTION/IM/JU/@ju2ty='currens'">c<xsl:value-of
                            select="BSECTION/IM/JU/@ju1sv"/>9999</xsl:when>
                    <xsl:when test="BSECTION/IM/JU/attribute::ju1sv">
                        <xsl:choose>
                            <xsl:when test="BSECTION/IM/JU/attribute::ju2sv">m<xsl:value-of
                                    select="BSECTION/IM/JU/@ju1sv"/>
                                <xsl:value-of select="BSECTION/IM/JU/@ju2sv"/>
                            </xsl:when>
                            <xsl:otherwise> s <xsl:value-of select="BSECTION/IM/JU/@ju1sv"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                <xsl:value-of select="'xx                u '"/>
                <xsl:value-of select="BSECTION/LG[1]/@lg"/>
                <xsl:value-of select="'  '"/>
            </marc:controlfield>
            <xsl:if test="BSECTION/NR/attribute::ty='lc'">
                <xsl:comment>Library of Congress Control Number </xsl:comment>
                <marc:datafield tag="010" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="BSECTION/NR/@nr"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:if>
            <xsl:for-each select="BSECTION/NR[@ty='isbn']">
                <xsl:comment>International Standard Book Number </xsl:comment>
                <marc:datafield tag="020" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="@nr"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <xsl:for-each select="BSECTION/NR[@ty='isbn13']">
                <xsl:comment>International Standard Book Number (ISBN13)</xsl:comment>
                <marc:datafield tag="020" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="@nr"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <xsl:for-each select="BSECTION/NR[@ty='issn']">
                <xsl:comment>International Standard Serial Number </xsl:comment>
                <marc:datafield tag="022" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="@nr"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <xsl:for-each select="BSECTION/NR[@ty='mm']">
                <xsl:comment>Other Standard Identifier</xsl:comment>
                <marc:datafield tag="024" ind1="8" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="@mm"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <xsl:for-each select="BSECTION/NT[@ty='br']">
                <xsl:comment>Other standard identifier: STCV Identifier</xsl:comment>
                <marc:datafield tag="024" ind1="7" ind2="0">
                    <marc:subfield code="2">
                        <xsl:text>STCV</xsl:text>
                    </marc:subfield>
                    <marc:subfield code="a">
                        <xsl:value-of
                            select="substring-before(substring-after(DATA,'STCV '),'&lt;')"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <xsl:for-each select="BSECTION/NR[@ty='fp']">
                <xsl:comment>Fingerprint Identifier</xsl:comment>
                <marc:datafield tag="026" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="@nr"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- tag 040: cataloguing source -->
            <xsl:comment>Cataloging Source </xsl:comment>
            <marc:datafield tag="040" ind1=" " ind2=" ">
                <marc:subfield code="a">http://webi.provant.be/brocade</marc:subfield>
            </marc:datafield>
            <!-- tag  041: language code: reeds gecodeerd in 008/35-37; herhalen? <xsl:value-of select="BSECTION/LG/@lg"/> -->
            <xsl:for-each select="BSECTION/LG">
                <xsl:comment>Language Code</xsl:comment>
                <marc:datafield tag="041" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="@lg"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- tag 080 udc number ; text string ook onder 650 added entries-->
            <xsl:for-each select="SSECTION/SU">
                <xsl:if test="substring(@ac, 4, 1)='u'">
                    <xsl:comment>Universal Decimal Classification Number</xsl:comment>
                    <marc:datafield tag="080" ind1=" " ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="substring(@ac, 6)"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:if>
            </xsl:for-each>
            <!-- tag 084: other classification number -->
            <!-- Q: welke classificaties zijn er in gebruik? 
            <xsl:for-each select="SSECTION/SU">
                <xsl:if test="substring(@ac, 4, 1)!='u'">
                    <marc:datafield tag="084" ind1=" " ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="@ac"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:if>
                </xsl:for-each> -->
            <!-- subjects met tags 'tv' onder 6XX -->
            <!-- tag 100: main entry personal name -->
            <!-- Hier eerste AU met @fu 'au' De ev. andere AU's met fu = "aut" of met fu verschillend van "aut", 
                worden als datafield 700 opgenomen (dixit BVV); dus ook wanneer er alleen auteurs met andere dan aut rol zijn-->
            <xsl:if test="BSECTION/AU/@fu='aut'">
                <xsl:comment>Main Entry - Personal Name</xsl:comment>
                <marc:datafield tag="100" ind1="1" ind2=" ">
                    <marc:subfield code="a"><xsl:value-of select="(BSECTION/AU[@fu='aut']/FN/DATA)[1]"/></marc:subfield>
                    <marc:subfield code="c">
                        <xsl:value-of select="(BSECTION/AU[@fu='aut']/EX/DATA)[1]"/>
                    </marc:subfield>
                    <marc:subfield code="0">
                        <xsl:value-of select="BSECTION/AU[@fu='aut'][1]/@ac"/>
                    </marc:subfield>
                    <marc:subfield code="4">
                        <xsl:value-of select="BSECTION/AU[@fu='aut'][1]/@fu"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:if>
            <!-- tag 110 main entry corporate name -->
            <!-- De eerste CA met @fu='aut', wanneer er geen AU met @fu='aut' is. De ev. tweede en volgende CA's met fu = "aut" of met fu verschillend van "aut", 
            worden als datafield 710 opgenomen (cfr. verderop in dit document) -->
            <xsl:choose>
                <xsl:when test="not(BSECTION/AU/@fu='aut')">
                    <xsl:if test="(BSECTION/CA/@fu='aut')[1]">
                        <xsl:comment>Main Entry - Corporate Name</xsl:comment>
                        <marc:datafield tag="110" ind1="2" ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="(BSECTION/CA/NM)[1]"/>
                            </marc:subfield>
                            <marc:subfield code="0">
                                <xsl:value-of select="(BSECTION/CA/@ac)[1]"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="(BSECTION/CA/@fu)[1]"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
            <!-- tag 210: abbreviated title: komt niet voor ?-->
            <!-- tag 222: key title: komt niet voor ?-->
            <!-- tag 240 uniform title: komt niet voor in huidige set, maar veiligheidshalve toegevoegd ; Moet via variable (? zie variable name=Title) omdat er een waarde uit attribuut moet worden gehaald-->
            <xsl:if test="BSECTION/TI/@ty='u'">
                <xsl:comment>Uniform Title</xsl:comment>
                <marc:datafield tag="240" ind1="1" ind2="0">
                    <marc:subfield code="a">
                        <xsl:value-of select="BSECTION/TI/DATA"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:if>
            <!-- tag 245 title statement -->
            <xsl:for-each select="BSECTION/TI">
                <xsl:if test="@ty='h'">
                    <xsl:comment>Title Statement</xsl:comment>
                    <!-- ind2 moet # nonfiling characters geven -->
                    <!-- ind2 mag max 1 cijfer bevatten. In brondata soms meer ("39") Alleen eerste teken wordt weerhouden-->
                    <xsl:variable name="titleNonFiling">
                        <xsl:value-of select="@ap"/>
                    </xsl:variable>
                    <xsl:variable name="titleNonFilingFirstCharacter">
                        <xsl:value-of select="substring($titleNonFiling,1,1)"/>
                    </xsl:variable>
                    <marc:datafield tag="245" ind1="1" ind2="{$titleNonFilingFirstCharacter}">
                        <!-- dit deel om subtitel te selecteren (na dubbelpunt) -->
                        <xsl:choose>
                            <xsl:when test="contains(TITLE/DATA,': ')">
                                <marc:subfield code="a"><xsl:value-of select="concat(substring-before(TITLE/DATA,':'),':')"/></marc:subfield>
                                <marc:subfield code="b"><xsl:value-of select="substring-after(TITLE/DATA,':')"/></marc:subfield>
                            </xsl:when>
                            <xsl:otherwise>
                                <marc:subfield code="a">
                                    <xsl:value-of select="TITLE/DATA"/>
                                </marc:subfield>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- onderdeel EX niet gedefinieerd in BVV; volgens BVV: NOTE@ty="ex" naar 584-->
                        <xsl:variable name="auteursvermelding">
                            <xsl:for-each select="../NT">
                                <xsl:if test="@ty='aut'">
                                    <xsl:value-of select="DATA"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <marc:subfield code="c">
                            <xsl:value-of select="$auteursvermelding"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:if>
                <!-- tag 246 varying form of title parallel titel, secundaire titel, meervoudige titel-->
                <xsl:choose>
                    <xsl:when test="@ty='p'">
                        <xsl:comment>Parallel Title Statement</xsl:comment>
                        <marc:datafield tag="246" ind1="1" ind2="1">
                            <marc:subfield code="a">
                                <xsl:value-of select="TITLE/DATA"/>
                            </marc:subfield>
                            <!-- title language enkel bewaard bij paralleltitels-->
                            <marc:subfield code="g"> Title language: <xsl:value-of select="@lg"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='v'">
                        <xsl:comment>Secondary Title Statement</xsl:comment>
                        <marc:datafield tag="246" ind1="1" ind2="3">
                            <marc:subfield code="a">
                                <xsl:value-of select="TITLE/DATA"/>
                            </marc:subfield>
                            <marc:subfield code="i">
                                <xsl:value-of select="'Secondary title:'"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='e'">
                        <xsl:comment>Secondary Title Statement</xsl:comment>
                        <marc:datafield tag="246" ind1="1" ind2="3">
                            <marc:subfield code="a">
                                <xsl:value-of select="TITLE/DATA"/>
                            </marc:subfield>
                            <marc:subfield code="i">
                                <xsl:value-of select="'Multiple title:'"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <!-- tag 246 varying form of title: sorting title -->
            <xsl:for-each select="BSECTION/TI/EX">
                <xsl:comment>Varying Form of Title</xsl:comment>
                <marc:datafield tag="246" ind1="3" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="DATA"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- tag 247 former title -->
            <!-- tag 250 edition statement -->
            <xsl:for-each select="BSECTION/ED">
                <xsl:comment>Edition statement</xsl:comment>
                <marc:datafield tag="250" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="DATA"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- tag 260 impressum -->
            <!-- jaar van uitgave construeren op basis van ju1sv(&ju2sv) en mask zoals gedefinieerd in ju1ty(& ju2ty). Sorteerwaarde wordt geparkeerd in 8-->
            <xsl:for-each select="BSECTION/IM">
                <xsl:comment>Publication, Distribution, etc. (Imprint) </xsl:comment>
                <xsl:variable name="impressumJaar1">
                    <xsl:choose>
                        <xsl:when test="JU/@ju1ty='YYYY'">
                            <xsl:value-of select="JU/@ju1sv"/>
                        </xsl:when>
                        <xsl:when test="JU/@ju1ty='[YYYY?]'">
                            <xsl:value-of select="concat('[',JU/@ju1sv,'?]')"/>
                        </xsl:when>
                        <xsl:when test="JU/@ju1ty='[YYYY]'">
                            <xsl:value-of select="concat('[',JU/@ju1sv,']')"/>
                        </xsl:when>
                        <xsl:when test="JU/@ju1ty='[c.YYYY]'">
                            <xsl:value-of select="concat('[',JU/@ju1sv,']')"/>
                        </xsl:when>
                        <xsl:when test="JU/@ju1ty='cop. YYYY'">
                            <xsl:value-of select="concat('cop. ',JU/@ju1sv)"/>
                        </xsl:when>
                        <xsl:when test="JU/@ju1ty='s.a.'">
                            <xsl:value-of select="'s.a.'"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="impressumJaarKoppelteken">
                    <xsl:if test="JU/@ju2sv!=''">
                        <xsl:value-of select="'-'"/>
                    </xsl:if>
                    <xsl:if test="JU/@ju2sv=''">
                        <xsl:value-of select="''"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="impressumJaar2">
                    <xsl:choose>
                        <xsl:when test="JU/@ju2ty='YYYY'">
                            <xsl:value-of select="JU/@ju2sv"/>
                        </xsl:when>
                        <xsl:when test="JU/@ju2ty='[YYYY?]'">
                            <xsl:value-of select="concat('[',JU/@ju2sv,'?]')"/>
                        </xsl:when>
                        <xsl:when test="JU/@ju2ty='[YYYY]'">
                            <xsl:value-of select="concat('[',JU/@ju2sv,']')"/>
                        </xsl:when>
                        <xsl:when test="JU/@ju2ty='cop. YYYY'">
                            <xsl:value-of select="concat('cop. ',JU/@ju2sv)"/>
                        </xsl:when>
                        <xsl:when test="JU/@ju2ty='[c.YYYY]'">
                            <xsl:value-of select="concat('cop. ',JU/@ju2sv)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="JU/@ju2sv"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <marc:datafield tag="260" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="PL"/>
                    </marc:subfield>
                    <marc:subfield code="b">
                        <xsl:value-of select="UG"/>
                    </marc:subfield>
                    <marc:subfield code="c">
                        <xsl:value-of
                            select="concat($impressumJaar1,$impressumJaarKoppelteken,$impressumJaar2)"
                        />
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- tag300 phys descr -->
            <xsl:for-each select="BSECTION/CO">
                <xsl:comment>Physical Description </xsl:comment>
                <marc:datafield tag="300" ind1=" " ind2=" ">
                    <xsl:if test="@pg != ''">
                        <marc:subfield code="a">
                            <xsl:value-of select="@pg"/>
                        </marc:subfield>
                    </xsl:if>
                    <xsl:if test="@il != ''">
                        <marc:subfield code="b">
                            <xsl:value-of select="@il"/>
                        </marc:subfield>
                    </xsl:if>
                    <xsl:if test="@fm != ''">
                        <marc:subfield code="c">
                            <xsl:value-of select="@fm"/>
                        </marc:subfield>
                    </xsl:if>
                    <xsl:if test="@sz != ''">
                        <marc:subfield code="c">
                            <xsl:value-of select="@sz"/>
                        </marc:subfield>
                    </xsl:if>
                    <xsl:if test="@ka != ''">
                        <marc:subfield code="c">
                            <xsl:value-of select="@ka"/>
                        </marc:subfield>
                    </xsl:if>
                </marc:datafield>
            </xsl:for-each>
            <!-- tag 340 phys medium -->
            <xsl:for-each select="BSECTION/DR">
                <xsl:comment>Physical Medium</xsl:comment>
                <marc:datafield tag="340" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="@dr"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- tag 490 series -->
            <xsl:for-each select="RSECTION/RELATION">
                <xsl:if test="@ty='vnr'">
                    <xsl:comment>Series Statement </xsl:comment>
                    <marc:datafield tag="490" ind1=" " ind2="0">
                        <marc:subfield code="a">
                            <xsl:value-of select="DATA"/>
                        </marc:subfield>
                        <marc:subfield code="v">
                            <xsl:value-of select="@sc"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:if>
            </xsl:for-each>
            <!-- 5XX note fields -->
            <xsl:for-each select="BSECTION/NT">
                <!-- 500 general note field voor @ty='alg'-->
                <xsl:choose>
                    <xsl:when test="@ty='alg'">
                        <xsl:comment>General Note</xsl:comment>
                        <marc:datafield tag="500" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <!-- @ty='lf' welk type? (geeft verschijningsfrquentie) -->
                    <xsl:when test="@ty='lf'">
                        <xsl:comment>General Note: frequency of appearance</xsl:comment>
                        <marc:datafield tag="500" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <!-- @ty='navt' welk type? (geeft holdings) -->
                    <xsl:when test="@ty='navt'">
                        <xsl:comment>General Note: holdings</xsl:comment>
                        <marc:datafield tag="500" ind1=" " ind2=" ">
                            <marc:subfield code="a"> Bezit: <xsl:value-of select="DATA"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <!-- 525 Supplement Note @ty='bevat' Alternatief is 501 With Note -->
                    <xsl:when test="@ty='bevat'">
                        <xsl:comment>Supplement Note: supplement</xsl:comment>
                        <marc:datafield tag="525" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <!-- 534 Original Version Note @ty='euitg' ("eerdere uitgave"?) -->
                    <xsl:when test="@ty='euitg'">
                        <xsl:comment>Original Version Note</xsl:comment>
                        <marc:datafield tag="534" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <!-- 580 Linking Entry Complexity Note @ty='cb' -->
                    <!-- GEKOPPELDE PUBLICATIE OOK IN 785 Linking entry -->
                    <xsl:when test="@ty='cb'">
                        <xsl:comment>Linking Entry Complexity Note</xsl:comment>
                        <marc:datafield tag="580" ind1=" " ind2=" ">
                            <marc:subfield code="a">Voortgezet door: <xsl:value-of select="DATA"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <!-- 580 Linking Entry Complexity Note @ty='co' -->
                    <!-- GEKOPPELDE PUBLICATIE OOK IN 780 Linking entry -->
                    <xsl:when test="@ty='co'">
                        <xsl:comment>Linking Entry Complexity Note</xsl:comment>
                        <marc:datafield tag="580" ind1=" " ind2=" ">
                            <marc:subfield code="a"> Voortzetting van: <xsl:value-of select="DATA"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='br'">
                        <xsl:comment>Electronic Location and Access</xsl:comment>
                        <marc:datafield tag="856" ind1="4" ind2="2">
                            <marc:subfield code="3">STCV entry</marc:subfield>
                            <marc:subfield code="u">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <!-- alle andere opmerkingen -->
                    <xsl:otherwise>
                        <xsl:comment>General Note: all other notes not recognized (yet)</xsl:comment>
                        <marc:datafield tag="500" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="@ty"/>: <xsl:value-of select="DATA"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:otherwise>
                    <!-- @ty='pag' welk type? (geeft paginavermelding van ts-artikel) -->
                    <!-- MOET OOK IN 78X Linking entry -->
                    <!-- @ty='uitnr' welk type? (geeft afleveringgegevens) -->
                    <!-- GEKOPPELDE PUBLICATIE OOK IN 78X Linking entry -->
                </xsl:choose>
            </xsl:for-each>
            <xsl:for-each select="SSECTION/SU">
                <xsl:choose>
                    <!-- 600  subject added entry personal name - komt niet voor-->
                    <!-- 610  subject added entry corporate name - komt niet voor-->
                    <!-- 648  subject added entry chron term komt - niet voor-->
                    <!-- 650  subject added entry topical term: enkel voor algemeen geaccepteerde thesauri e.d., dus hier voor UDC -->
                    <!-- UDC codes ook al in 080; hier hernomen met tekststring -->
                    <xsl:when test="substring(@ac, 4, 1)='u'">
                        <xsl:comment>Subject Added Entry - Topical Term </xsl:comment>
                        <marc:datafield tag="650" ind1=" " ind2="7">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <!-- volgens BVV subfield code 2, maar kan ook 0 zijn? -->
                            <marc:subfield code="2">
                                <xsl:value-of select="@ac"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <!-- 653  opm.: 650  subject added entry topical term: enkel voor algemeen geaccepteerde thesauri e.d. Daarom 653 gebruikt-->
                    <xsl:when test="substring(@ac, 4, 2)='tv'">
                        <!-- hierbij worden ook elementen met attributen tvm etc verwerkt -->
                        <xsl:comment>2Index Term - Uncontrolled </xsl:comment>
                        <marc:datafield tag="653" ind1=" " ind2="7">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="2">
                                <xsl:value-of select="@ac"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="substring(@ac, 4, 3)='gen'">
                        <xsl:comment>Index Term - Genre/Form</xsl:comment>
                        <marc:datafield tag="655" ind1=" " ind2="7">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="0">
                                <xsl:value-of select="@ac"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="substring(@ac, 4, 2)='g.'">
                        <xsl:comment>Subject Added Entry - Geographic Name</xsl:comment>
                        <marc:datafield tag="651" ind1=" " ind2="7">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="0">
                                <xsl:value-of select="@ac"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <!--  <xsl:for-each select="BSECTION/LM"/> -->
            <xsl:comment>Index Term - Genre/Form derived from LM (lidmaatschap)</xsl:comment>
            <!-- <marc:datafield tag="655" ind1=" " ind2="4">
                 
                <marc:subfield code="a">
                    <xsl:choose>
                        <xsl:when test="BSECTION/LM/@lm='boek'">boek</xsl:when>
                        <xsl:when test="BSECTION/LM/@lm='ts'">tijdschrift</xsl:when>
                        <xsl:when test="BSECTION/LM/@lm='art'">artikel</xsl:when>
                        <xsl:when test="BSECTION/LM/@lm='mm'">multimedia</xsl:when>
                        <xsl:when test="BSECTION/LM/@lm='docmap'">documentatiemap</xsl:when>
                        <xsl:otherwise>ander</xsl:otherwise>
                    </xsl:choose>
                </marc:subfield>
                </marc:datafield> -->
            <xsl:for-each select="BSECTION/LM">
                <marc:datafield tag="655" ind1=" " ind2="4">
                    <!-- een item kan meerdere lidmaatschappen hebben? -->
                    <marc:subfield code="a">
                        <xsl:choose>
                            <xsl:when test="@lm='boek'">boek</xsl:when>
                            <xsl:when test="@lm='ts'">tijdschrift</xsl:when>
                            <xsl:when test="@lm='art'">artikel</xsl:when>
                            <xsl:when test="@lm='mm'">multimedia</xsl:when>
                            <xsl:when test="@lm='docmap'">documentatiemap</xsl:when>
                            <xsl:when test="@lm='od'">oude druk</xsl:when>
                            <xsl:otherwise>ander</xsl:otherwise>
                        </xsl:choose>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- 700  added entry personal name -->
            <!-- maak string van eerste aut -->
            <xsl:variable name="firstAut">
                <xsl:value-of select="(BSECTION/AU[@fu='aut']/FN/DATA)[1]"/>
            </xsl:variable>
            <!-- alle aut behalve eerste aut -->
            <xsl:for-each select="BSECTION/AU[(@fu='aut') and (FN/DATA!=$firstAut)]">
                <xsl:comment>Added Entry - Personal Name (all authors except first one)</xsl:comment>
                <marc:datafield tag="700" ind1="1" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="FN/DATA"/>
                    </marc:subfield>
                    <marc:subfield code="0">
                        <xsl:value-of select="@ac"/>
                    </marc:subfield>
                    <marc:subfield code="4">
                        <xsl:value-of select="@fu"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- alle personen behalve aut -->
            <xsl:for-each select="BSECTION/AU[not(@fu='aut')]">
                <xsl:comment>Added Entry - Personal Name (all persons with other function than 'author')</xsl:comment>
                <marc:datafield tag="700" ind1="1" ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="FN/DATA"/>
                    </marc:subfield>
                    <marc:subfield code="0">
                        <xsl:value-of select="@ac"/>
                    </marc:subfield>
                    <marc:subfield code="4">
                        <xsl:value-of select="@fu"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- 710 added entry corporate name -->
            <!-- alle CA behalve degen die in 110 staat (i.e. CA met @fu=aut wanneer er geen AU is met @fu=aut) -->
            <!-- maak string van eerste aut -->
            <!-- NOG NIET OK -->
            <!-- maak string van eerste Caut wordt gebruikt om te vermijden dat deze opnieuw verschijnt in 710-->
            <xsl:variable name="firstCAut">
                <xsl:if test="not(BSECTION/AU/@fu='aut') and BSECTION/CA/@fu='aut'">
                    <xsl:value-of select="BSECTION/CA[1]/NM"/>
                </xsl:if>
                <!--<xsl:value-of
                    select="(BSECTION/CA/(@fu='aut')/NM)[1]"/>-->
            </xsl:variable>
            <xsl:comment>Added Entry - Corporate Name (all coprorate authors, except when CA is already mentioned as main entry 100)</xsl:comment>
            <xsl:for-each select="BSECTION/CA">
                <xsl:if test="(NM!=($firstCAut))">
                    <marc:datafield tag="710" ind1="1" ind2=" ">
                        <marc:subfield code="a">
                            <xsl:value-of select="NM/DATA"/>
                        </marc:subfield>
                        <marc:subfield code="0">
                            <xsl:value-of select="@ac"/>
                        </marc:subfield>
                        <marc:subfield code="4">
                            <xsl:value-of select="@fu"/>
                        </marc:subfield>
                    </marc:datafield>
                </xsl:if>
            </xsl:for-each>
            <!-- 78X OOK UIT NT velden (zie 5XX hoger)? Daar is echter geen c:pca:nummer opgenomen -->
            <!-- GEKOPPELDE PUBLICATIE OOK IN 785 Linking entry -->
            <xsl:for-each select="RSECTION/RELATION">
                <xsl:choose>
                    <xsl:when test="@ty='vnr'">
                        <xsl:comment>Host Item Entry (vnr)</xsl:comment>
                        <marc:datafield tag="773" ind1="1" ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='rnv'">
                        <xsl:comment>Constituent Unit Entry (rnv)</xsl:comment>
                        <marc:datafield tag="774" ind1="0" ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='an'">
                        <xsl:comment>Host Item Entry (an)</xsl:comment>
                        <marc:datafield tag="773" ind1="1" ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='na'">
                        <xsl:comment>Constituent Unit Entry (na)</xsl:comment>
                        <marc:datafield tag="774" ind1="0" ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='ong'">
                        <xsl:comment>Constituent Unit Entry (ong)</xsl:comment>
                        <marc:datafield tag="774" ind1="1" ind2=" ">
                            <marc:subfield code="t">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='gno'">
                        <xsl:comment>CHost Item Entry (gno)</xsl:comment>
                        <marc:datafield tag="773" ind1="1" ind2=" ">
                            <marc:subfield code="t">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='atd'">
                        <xsl:comment>Constituent Unit Entry (atd)</xsl:comment>
                        <marc:datafield tag="774" ind1="1" ind2=" ">
                            <marc:subfield code="t">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='tda'">
                        <xsl:comment>Host Item Entry (dta)</xsl:comment>
                        <marc:datafield tag="773" ind1="1" ind2=" ">
                            <marc:subfield code="t">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='oz'">
                        <xsl:comment>Constituent Unit Entry (oz)</xsl:comment>
                        <marc:datafield tag="774" ind1="1" ind2=" ">
                            <marc:subfield code="t">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='zo'">
                        <xsl:comment>Host Item Entry (zo)</xsl:comment>
                        <marc:datafield tag="773" ind1="1" ind2=" ">
                            <marc:subfield code="t">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='ewi'">
                        <xsl:comment>Issued with (ewi)</xsl:comment>
                        <marc:datafield tag="777" ind1="1" ind2="0">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='wi'">
                        <xsl:comment>Constituent Unit Entry (wi)</xsl:comment>
                        <marc:datafield tag="774" ind1="1" ind2="0">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='in'">
                        <xsl:comment>Host Item Entry (in)</xsl:comment>
                        <marc:datafield tag="773" ind1="1" ind2="0">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='iwe'">
                        <!-- ewi and iwe both converted to 777 (horizontal relationship) -->
                        <xsl:comment>Issued with</xsl:comment>
                        <marc:datafield tag="777" ind1="1" ind2="0">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='co'">
                        <xsl:comment>Preceding Entry (co)</xsl:comment>
                        <marc:datafield tag="780" ind1="1" ind2="0">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <xsl:when test="@ty='cb'">
                        <xsl:comment>Succeeding Entry (cb)</xsl:comment>
                        <marc:datafield tag="785" ind1="1" ind2="0">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                    <!-- remaining in in 787 - if any -->
                    <xsl:otherwise>
                        <xsl:comment>Other Relationship Entry</xsl:comment>
                        <marc:datafield tag="787" ind1="1" ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="DATA"/>
                            </marc:subfield>
                            <marc:subfield code="g">
                                <xsl:value-of select="@sc"/>
                            </marc:subfield>
                            <marc:subfield code="w">
                                <xsl:value-of select="@cloi"/>
                            </marc:subfield>
                            <marc:subfield code="4">
                                <xsl:value-of select="@ty"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <!-- enkel Holdings waar library = MOMU, FOMU, MUST -->
            <xsl:for-each select="HSECTION/LIB/HOLDING">
                <xsl:choose>
                    <xsl:when
                        test="(../@library='MOMU') or (../@library='FOMU') or (../@library='MUST')">
                        <xsl:comment>Location</xsl:comment>
                        <marc:datafield tag="852" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="../@library"/>
                            </marc:subfield>
                            <!-- verwoording locatie: voorkeur voor letterlijke verwoording, anders code @ty -->
                            <xsl:choose>
                                <xsl:when test="boolean(DISPLAY/DATA)">
                                    <marc:subfield code="b">
                                        <xsl:value-of select="DISPLAY/DATA"/>
                                    </marc:subfield>
                                </xsl:when>
                                <xsl:when test="boolean(@ty)">
                                    <marc:subfield code="b">
                                        <xsl:value-of select="@ty"/>
                                    </marc:subfield>
                                </xsl:when>
                            </xsl:choose>
                            <marc:subfield code="c">
                                <xsl:value-of select="PK/DATA"/>
                            </marc:subfield>
                            <marc:subfield code="3">
                                <xsl:value-of select="PKBZ/DATA"/>
                            </marc:subfield>
                            <marc:subfield code="z">
                                <xsl:value-of select="PKNOTE/DATA"/>
                            </marc:subfield>
                            <!-- splits barcode en inv nr uit OBJINX -->
                            <xsl:for-each select="VOL/OBJ/OBJINX">
                                <xsl:if test="(@ty='inv')">
                                    <marc:subfield code="p">
                                        <xsl:value-of select="DATA"/>
                                    </marc:subfield>
                                </xsl:if>
                            </xsl:for-each>
                            <!-- barcodenummer moet niet worden bewaard Indien wel: geschreven naar $t, maar dit is niet helemaal correct)
                            <xsl:for-each select="VOL/OBJ/OBJINX">
                                <xsl:if test="(@ty='bc')">
                                    <marc:subfield code="t">
                                        <xsl:value-of select="DATA"/>
                                    </marc:subfield>
                                </xsl:if>
                                </xsl:for-each> -->
                            <!-- splits barcode en inv nr uit OBJINX -->
                            <marc:subfield code="x">
                                <xsl:value-of select="VOL/OBJ/OBJNOTE/DATA"/>
                            </marc:subfield>
                            <marc:subfield code="x">
                                <xsl:value-of select="VOL/OBJ/OBJNOTEI/DATA"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <!--<xsl:for-each select="HSECTION/LIB">
                <xsl:choose>
                    <xsl:when
                        test="(@library='MOMU') or (@library='FOMU') or (@library='MUST')">
                        <xsl:comment>Location</xsl:comment>
                        <marc:datafield tag="852" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="@library"/>
                            </marc:subfield>
                            <marc:subfield code="b">
                                <xsl:value-of select="HOLDING/@ty"/>
                            </marc:subfield>
                            <marc:subfield code="c">
                                <xsl:value-of select="HOLDING/PK/DATA"/>
                            </marc:subfield>
                            <marc:subfield code="3">
                                <xsl:value-of select="HOLDING/PKBZ"/>
                            </marc:subfield>
                            <marc:subfield code="z">
                                <xsl:value-of select="HOLDING/PKNOTE/DATA"/>
                            </marc:subfield>
                            <marc:subfield code="p">
                                <xsl:value-of select="HOLDING/VOL/OBJ/OBJINX/DATA"/>
                            </marc:subfield>
                            <marc:subfield code="x">
                                <xsl:value-of select="HOLDING/VOL/OBJ/OBJNOTE/DATA"/>
                            </marc:subfield>
                            
                        </marc:datafield>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>-->
            <xsl:for-each select="CSECTION/IN">
                <xsl:comment>Electronic Location and Access</xsl:comment>
                <marc:datafield tag="856" ind1="4" ind2=" ">
                    <marc:subfield code="u">
                        <xsl:value-of select="@url"/>
                    </marc:subfield>
                    <marc:subfield code="n">
                        <xsl:value-of select="@loc"/>
                    </marc:subfield>
                    <marc:subfield code="z">
                        <xsl:value-of select="NOTE/DATA"/>
                    </marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <xsl:comment>Description Conversion Information</xsl:comment>
            <marc:datafield tag="884" ind1=" " ind2=" ">
                <marc:subfield code="a">CATXML to MARCXML conversie </marc:subfield>
                <marc:subfield code="g">
                    <xsl:value-of select="current-date()"/>
                </marc:subfield>
                <marc:subfield code="k">
                    <xsl:value-of select="@cloi"/>
                </marc:subfield>
                <marc:subfield code="q">datable.be
                </marc:subfield>
                <marc:subfield code="h">https://github.com/hvanstappen/CAT2MARCXML
                </marc:subfield>
            </marc:datafield>
            <!-- naam creator record en naam laatste wijziging: geen corresponderend veld in MARC21 -->
            <xsl:comment>Non-MARC Information Field: record created by</xsl:comment>
            <marc:datafield tag="887" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:value-of select="TSECTION/@cp"/>
                </marc:subfield>
                <marc:subfield code="2">http://webi.provant.be/brocade/catalog/catxml.dtd
                    TSECTION/@cp [record created by]</marc:subfield>
            </marc:datafield>
            <xsl:comment>Non-MARC Information Field: record last modified by</xsl:comment>
            <marc:datafield tag="887" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:value-of select="TSECTION/@mp"/>
                </marc:subfield>
                <marc:subfield code="2"> http://webi.provant.be/brocade/catalog/catxml.dtd
                    TSECTION/@mp [record last modified by]</marc:subfield>
            </marc:datafield>
            <xsl:comment>Non-MARC Information Field: record creation date, rounded to the month</xsl:comment>
            <marc:datafield tag="887" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:value-of
                        select="concat(floor(number($JaarQuotientcd)),'-',$MaandQuotient2cd,'-00')"
                    />
                </marc:subfield>
                <marc:subfield code="2"> http://webi.provant.be/brocade/catalog/catxml.dtd
                    TSECTION/@cd [record creation date]</marc:subfield>
            </marc:datafield>
            <xsl:comment>Non-MARC Information Field: record modification date, rounded to the month</xsl:comment>
            <marc:datafield tag="887" ind1=" " ind2=" ">
                <marc:subfield code="a">
                    <xsl:value-of
                        select="concat(floor(number($JaarQuotient)),'-',$MaandQuotient2,'-00')"/>
                </marc:subfield>
                <marc:subfield code="2"> http://webi.provant.be/brocade/catalog/catxml.dtd
                    TSECTION/@md [record modification date]</marc:subfield>
            </marc:datafield>
            <xsl:for-each select="BSECTION/IM[1]">
                <xsl:comment>Non-MARC Information Field: publication start date as sort date (format YYYY)</xsl:comment>
                <marc:datafield tag="887" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="JU/@ju1sv"/>
                    </marc:subfield>
                    <marc:subfield code="2"> http://webi.provant.be/brocade/catalog/catxml.dtd
                        BSECTION/IM/JU/@ju1sv [publication start date as sort date]</marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <xsl:comment>Non-MARC Information Field: publication end date as sort date (format YYYY)</xsl:comment>
            <xsl:for-each select="BSECTION/IM[1]">
                <marc:datafield tag="887" ind1=" " ind2=" ">
                    <marc:subfield code="a">
                        <xsl:value-of select="BSECTION/IM[1]/JU/@ju2sv"/>
                    </marc:subfield>
                    <marc:subfield code="2"> http://webi.provant.be/brocade/catalog/catxml.dtd
                        BSECTION/IM/JU/@ju2sv [publication end date as sort date]</marc:subfield>
                </marc:datafield>
            </xsl:for-each>
            <!-- additional mapping to 952: KOHA holdings datafields -->
            <xsl:for-each select="HSECTION/LIB/HOLDING/VOL/OBJ">
                <xsl:choose>
                    <xsl:when
                        test="(../../../@library='MOMU') or (../../../@library='FOMU') or (../../../@library='MUST')">
                        <xsl:comment>Location</xsl:comment>
                        <marc:datafield tag="952" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="../../../@library"/>
                            </marc:subfield>
                            <!-- verwoording locatie: voorkeur voor letterlijke verwoording, anders code @ty -->
                            <xsl:choose>
                                <xsl:when test="boolean(../../DISPLAY/DATA)">
                                    <marc:subfield code="b">
                                        <xsl:value-of select="../../DISPLAY/DATA"/>
                                    </marc:subfield>
                                </xsl:when>
                                <xsl:when test="../../boolean(@ty)">
                                    <marc:subfield code="b">
                                        <xsl:value-of select="../../@ty"/>
                                    </marc:subfield>
                                </xsl:when>
                            </xsl:choose>
                            <marc:subfield code="c">
                                <xsl:value-of select="../../PK/DATA"/>
                            </marc:subfield>
                            <xsl:comment>Source of acquisition (KOHA)</xsl:comment>
                            <marc:subfield code="e">
                                <xsl:value-of select="@sg"/>
                            </marc:subfield>
                            <marc:subfield code="o">
                                <xsl:value-of select="@ploi"/>
                            </marc:subfield>
                            <marc:subfield code="3">
                                <xsl:value-of select="../../PKBZ/DATA"/>
                            </marc:subfield>
                            <marc:subfield code="z">
                                <xsl:value-of select="PKNOTE/DATA"/>
                            </marc:subfield>
                            <!-- splits barcode en inv nr uit OBJINX -->
                            <xsl:for-each select="OBJINX">
                                <xsl:if test="(@ty='inv')">
                                    <xsl:comment>Inventory number (KOHA)</xsl:comment>
                                    <marc:subfield code="i">
                                        <xsl:value-of select="DATA"/>
                                    </marc:subfield>
                                </xsl:if>
                            </xsl:for-each>
                            <!-- barcodenummer moet niet worden bewaard, maar kan naar $p)-->
                                <xsl:for-each select="OBJINX">
                                <xsl:if test="(@ty='bc')">
                                <marc:subfield code="p">
                                <xsl:value-of select="DATA"/>
                                </marc:subfield>
                                </xsl:if>
                                </xsl:for-each>
                            <!-- splits barcode en inv nr uit OBJINX -->
                            <marc:subfield code="x">
                                <xsl:value-of select="OBJNOTE/DATA"/>
                            </marc:subfield>
                            <marc:subfield code="x">
                                <xsl:value-of select="OBJNOTEI/DATA"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </marc:record>
    </xsl:template>
</xsl:stylesheet>
