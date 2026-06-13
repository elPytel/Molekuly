<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:param name="title" select="'Molekuly - Cards Deck'"/>
  <xsl:param name="mode" select="'front'"/>
  <xsl:param name="colorMode" select="'color'"/>

  <xsl:variable name="cardsPerPage" select="9"/>

  <xsl:template name="generate-electrons">
    <xsl:param name="count" select="0"/>
    <xsl:if test="number($count) &gt; 0">
      <div class="electron-dot"></div>
      <xsl:call-template name="generate-electrons">
        <xsl:with-param name="count" select="number($count) - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/cards">
    <html>
      <head>
        <meta charset="UTF-8"/>
        <title><xsl:value-of select="$title"/></title>
        <style>
          @page { size: A4; margin: 10mm; }
          html, body { margin: 0; padding: 0; }
          body { font-family: "sans-serif", Helvetica, Arial, sans-serif; color: #111; background: #eee; }
          @media print { body { background: #fff; } }

          .page { page-break-after: always; }
          .page:last-child { page-break-after: auto; }

          .sheet {
            width: 100%;
            display: grid;
            grid-template-columns: repeat(3, 63mm);
            grid-template-rows: repeat(3, 88mm);
            justify-content: center;
            align-content: start;
          }

          /* Base poker card template container */
          .card {
            position: relative;
            box-sizing: border-box;
            width: 63mm;
            height: 88mm;
            border: 0.35mm solid #111;
            border-radius: 2mm;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            background: #ffffff;
          }

          /* Render print cut marks */
          .card:before, .card:after {
            content: ""; position: absolute; left: -2mm; top: -2mm; right: -2mm; bottom: -2mm; pointer-events: none;
            background:
              linear-gradient(#111,#111) left 0 top 0 / 3mm 0.25mm no-repeat,
              linear-gradient(#111,#111) left 0 top 0 / 0.25mm 3mm no-repeat,
              linear-gradient(#111,#111) right 0 top 0 / 3mm 0.25mm no-repeat,
              linear-gradient(#111,#111) right 0 top 0 / 0.25mm 3mm no-repeat,
              linear-gradient(#111,#111) left 0 bottom 0 / 3mm 0.25mm no-repeat,
              linear-gradient(#111,#111) left 0 bottom 0 / 0.25mm 3mm no-repeat,
              linear-gradient(#111,#111) right 0 bottom 0 / 3mm 0.25mm no-repeat,
              linear-gradient(#111,#111) right 0 bottom 0 / 0.25mm 3mm no-repeat;
            opacity: 0.5;
            z-index: 10;
          }

          /* =========================================
             ATOM CARD STYLES (Minimalistic layout)
             ========================================= */
          .card.atom-card {
            justify-content: space-between;
            align-items: center;
            padding: 5mm;
            text-align: center;
          }

          .atom-weight {
            font-size: 4mm;
            font-weight: bold;
            align-self: flex-end;
          }

          /* Central core containing the symbol and shell ring */
          .atom-core {
            position: relative;
            width: 32mm;
            height: 32mm;
            border-radius: 50%;
            border: 0.5mm dashed rgba(0,0,0,0.3);
            display: flex;
            align-items: center;
            justify-content: center;
          }

          .atom-nucleus {
            width: 20mm;
            height: 20mm;
            border-radius: 50%;
            border: 0.5mm solid #111;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 8mm;
            font-weight: bold;
            box-shadow: 0 1mm 2mm rgba(0,0,0,0.15);
          }

          .atom-meta {
            margin-bottom: 2mm;
          }

          .atom-name {
            font-size: 4.5mm;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.5mm;
          }

          /* Position valence electrons around the shell ring */
          .valence-container {
            position: absolute;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
          }

          .electron-dot {
            position: absolute;
            width: 3mm;
            height: 3mm;
            background: #111;
            border-radius: 50%;
            border: 0.3mm solid #fff;
          }

           /* ========================================================
             CLEAN LEWIS DOT GRID SYSTEM (N-S-E-W Cardinal Alignment)
             Single dots centered at 14.5mm, pairs split at 11mm &amp; 18mm
             ======================================================== */
          
           /* 1 Valence Electron (H, Na, K) -> 1 open slot at North */
           .e-count-1 .electron-dot:nth-child(1) { top: -1.5mm; left: 14.5mm; }

          /* 2 Valence Electrons -> 2 open slots (North &amp; South) */
           .e-count-2 .electron-dot:nth-child(1) { top: -1.5mm; left: 14.5mm; }
           .e-count-2 .electron-dot:nth-child(2) { bottom: -1.5mm; left: 14.5mm; }

           /* 3 Valence Electrons -> 3 open slots (North, East, West) */
           .e-count-3 .electron-dot:nth-child(1) { top: -1.5mm; left: 14.5mm; }
           .e-count-3 .electron-dot:nth-child(2) { top: 14.5mm; right: -1.5mm; }
           .e-count-3 .electron-dot:nth-child(3) { top: 14.5mm; left: -1.5mm; }

           /* 4 Valence Electrons (C) -> 4 open slots (Perfect Cross) */
           .e-count-4 .electron-dot:nth-child(1) { top: -1.5mm; left: 14.5mm; }
           .e-count-4 .electron-dot:nth-child(2) { bottom: -1.5mm; left: 14.5mm; }
           .e-count-4 .electron-dot:nth-child(3) { top: 14.5mm; right: -1.5mm; }
           .e-count-4 .electron-dot:nth-child(4) { top: 14.5mm; left: -1.5mm; }

           /* 5 Valence Electrons (N, P) -> 1 paired slot (North), 3 open slots (S, E, W) */
           .e-count-5 .electron-dot:nth-child(1) { top: -1.5mm; left: 11mm; }
           .e-count-5 .electron-dot:nth-child(2) { top: -1.5mm; left: 18mm; }
           .e-count-5 .electron-dot:nth-child(3) { bottom: -1.5mm; left: 14.5mm; }
           .e-count-5 .electron-dot:nth-child(4) { top: 14.5mm; right: -1.5mm; }
           .e-count-5 .electron-dot:nth-child(5) { top: 14.5mm; left: -1.5mm; }

           /* 6 Valence Electrons (O, S) -> 2 paired slots (North, South), 2 open slots (E, W) */
           .e-count-6 .electron-dot:nth-child(1) { top: -1.5mm; left: 11mm; }
           .e-count-6 .electron-dot:nth-child(2) { top: -1.5mm; left: 18mm; }
           .e-count-6 .electron-dot:nth-child(3) { bottom: -1.5mm; left: 11mm; }
           .e-count-6 .electron-dot:nth-child(4) { bottom: -1.5mm; left: 18mm; }
           .e-count-6 .electron-dot:nth-child(5) { top: 14.5mm; right: -1.5mm; }
           .e-count-6 .electron-dot:nth-child(6) { top: 14.5mm; left: -1.5mm; }

           /* 7 Valence Electrons (Cl) -> 3 paired slots (N, S, E), 1 open slot (West) */
           .e-count-7 .electron-dot:nth-child(1) { top: -1.5mm; left: 11mm; }
           .e-count-7 .electron-dot:nth-child(2) { top: -1.5mm; left: 18mm; }
           .e-count-7 .electron-dot:nth-child(3) { bottom: -1.5mm; left: 11mm; }
           .e-count-7 .electron-dot:nth-child(4) { bottom: -1.5mm; left: 18mm; }
           .e-count-7 .electron-dot:nth-child(5) { right: -1.5mm; top: 11mm; }
           .e-count-7 .electron-dot:nth-child(6) { right: -1.5mm; top: 18mm; }
           .e-count-7 .electron-dot:nth-child(7) { top: 14.5mm; left: -1.5mm; }

           /* 8 Valence Electrons -> 4 paired slots (Full Stable Octet) */
           .e-count-8 .electron-dot:nth-child(1) { top: -1.5mm; left: 11mm; }
           .e-count-8 .electron-dot:nth-child(2) { top: -1.5mm; left: 18mm; }
           .e-count-8 .electron-dot:nth-child(3) { bottom: -1.5mm; left: 11mm; }
           .e-count-8 .electron-dot:nth-child(4) { bottom: -1.5mm; left: 18mm; }
           .e-count-8 .electron-dot:nth-child(5) { right: -1.5mm; top: 11mm; }
           .e-count-8 .electron-dot:nth-child(6) { right: -1.5mm; top: 18mm; }
           .e-count-8 .electron-dot:nth-child(7) { left: -1.5mm; top: 11mm; }
           .e-count-8 .electron-dot:nth-child(8) { left: -1.5mm; top: 18mm; }


          /* =========================================
             MOLECULE CARD STYLES (Contract layout)
             ========================================= */
          .card.molecule-card {
            background: #fdfbf7;
          }

          .molecule-header {
            padding: 3mm;
            background: #2c3e50;
            color: #fff;
            display: flex;
            justify-content: space-between;
            align-items: center;
            height: 12mm;
            box-sizing: border-box;
          }

          .molecule-title {
            font-weight: bold;
            font-size: 4.2mm;
            line-height: 1.1;
          }

          .molecule-points {
            background: #f1c40f;
            color: #111;
            padding: 1mm 2.5mm;
            font-weight: bold;
            border-radius: 1mm;
            font-size: 3.8mm;
          }

          .molecule-art {
            width: 100%;
            height: 42mm;
            background-size: contain;
            background-repeat: no-repeat;
            background-position: center;
            background-color: #ffffff;
            border-bottom: 0.3mm solid #ddd;
            box-sizing: border-box;
            padding: 2mm;
          }

          .molecule-footer {
            flex-grow: 1;
            padding: 3mm;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-sizing: border-box;
            background: #fff;
          }

          .molecule-formula {
            font-family: monospace;
            font-size: 4.5mm;
            font-weight: bold;
            color: #c0392b;
            text-align: center;
            margin-bottom: 1.5mm;
          }

          .molecule-lore {
            font-size: 3.1mm;
            line-height: 1.3;
            color: #555;
            text-align: justify;
            font-style: italic;
          }

          /* =========================================
             CARD BACK STYLES
             ========================================= */
          .card.back {
            background: #2c3e50;
            color: #f1c40f;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: center;
            padding: 8mm 4mm;
            box-sizing: border-box;
            border: 0.5mm solid #f1c40f;
          }

          .back-banner {
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 2px;
            font-size: 5mm;
            text-align: center;
          }

          .back-banner.bottom {
            transform: rotate(180deg);
          }

          .back-logo {
            font-size: 10mm;
            border: 1mm solid #f1c40f;
            border-radius: 50%;
            width: 18mm;
            height: 18mm;
            display: flex;
            align-items: center;
            justify-content: center;
          }
        </style>
      </head>
      <body>
        <xsl:choose>
          <xsl:when test="$mode='both'"><xsl:call-template name="render-pages-interleaved"/></xsl:when>
          <xsl:when test="$mode='front'">
            <xsl:call-template name="render-pages"><xsl:with-param name="side" select="'front'"/></xsl:call-template>
          </xsl:when>
          <xsl:when test="$mode='back'">
            <xsl:call-template name="render-pages"><xsl:with-param name="side" select="'back'"/></xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="sum-counts">
    <xsl:param name="nodes"/>
    <xsl:choose>
      <xsl:when test="not($nodes)">0</xsl:when>
      <xsl:otherwise>
        <xsl:variable name="first" select="$nodes[1]"/>
        <xsl:variable name="c">
          <xsl:choose>
            <xsl:when test="string-length(normalize-space($first/@count)) &gt; 0"><xsl:value-of select="number($first/@count)"/></xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="rest">
          <xsl:call-template name="sum-counts">
            <xsl:with-param name="nodes" select="$nodes[position() &gt; 1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="number($c) + number($rest)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="render-pages">
    <xsl:param name="side"/>
    <xsl:variable name="totalCount">
      <xsl:call-template name="sum-counts">
        <xsl:with-param name="nodes" select="/cards/atoms/atom | /cards/molecules/molecule"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="pages-loop">
      <xsl:with-param name="total" select="$totalCount"/>
      <xsl:with-param name="cur" select="1"/>
      <xsl:with-param name="side" select="$side"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="render-pages-interleaved">
    <xsl:variable name="totalCount">
      <xsl:call-template name="sum-counts">
        <xsl:with-param name="nodes" select="/cards/atoms/atom | /cards/molecules/molecule"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="pages" select="ceiling(number($totalCount) div $cardsPerPage)"/>
    <xsl:call-template name="pages-interleaved-loop">
      <xsl:with-param name="pages" select="$pages"/>
      <xsl:with-param name="i" select="0"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="pages-interleaved-loop">
    <xsl:param name="pages"/>
    <xsl:param name="i" select="0"/>
    <xsl:if test="number($i) &lt; number($pages)">
      <xsl:variable name="startPos" select="$i * $cardsPerPage + 1"/>
      <div class="page"><div class="sheet"><xsl:call-template name="render-9"><xsl:with-param name="side" select="'front'"/><xsl:with-param name="startPos" select="$startPos"/></xsl:call-template></div></div>
      <div class="page"><div class="sheet"><xsl:call-template name="render-9"><xsl:with-param name="side" select="'back'"/><xsl:with-param name="startPos" select="$startPos"/></xsl:call-template></div></div>
      <xsl:call-template name="pages-interleaved-loop"><xsl:with-param name="pages" select="$pages"/><xsl:with-param name="i" select="$i + 1"/></xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="pages-loop">
    <xsl:param name="total"/>
    <xsl:param name="cur" select="1"/>
    <xsl:param name="side"/>
    <xsl:if test="number($cur) &lt;= number($total)">
      <div class="page">
        <div class="sheet"><xsl:call-template name="render-9"><xsl:with-param name="side" select="$side"/><xsl:with-param name="startPos" select="$cur"/></xsl:call-template></div>
      </div>
      <xsl:call-template name="pages-loop"><xsl:with-param name="total" select="$total"/><xsl:with-param name="cur" select="$cur + $cardsPerPage"/><xsl:with-param name="side" select="$side"/></xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-9">
    <xsl:param name="side"/>
    <xsl:param name="startPos"/>
    <xsl:variable name="all" select="/cards/atoms/atom | /cards/molecules/molecule"/>
    <xsl:call-template name="render-slot"><xsl:with-param name="side" select="$side"/><xsl:with-param name="n" select="$startPos + 0"/><xsl:with-param name="all" select="$all"/></xsl:call-template>
    <xsl:call-template name="render-slot"><xsl:with-param name="side" select="$side"/><xsl:with-param name="n" select="$startPos + 1"/><xsl:with-param name="all" select="$all"/></xsl:call-template>
    <xsl:call-template name="render-slot"><xsl:with-param name="side" select="$side"/><xsl:with-param name="n" select="$startPos + 2"/><xsl:with-param name="all" select="$all"/></xsl:call-template>
    <xsl:call-template name="render-slot"><xsl:with-param name="side" select="$side"/><xsl:with-param name="n" select="$startPos + 3"/><xsl:with-param name="all" select="$all"/></xsl:call-template>
    <xsl:call-template name="render-slot"><xsl:with-param name="side" select="$side"/><xsl:with-param name="n" select="$startPos + 4"/><xsl:with-param name="all" select="$all"/></xsl:call-template>
    <xsl:call-template name="render-slot"><xsl:with-param name="side" select="$side"/><xsl:with-param name="n" select="$startPos + 5"/><xsl:with-param name="all" select="$all"/></xsl:call-template>
    <xsl:call-template name="render-slot"><xsl:with-param name="side" select="$side"/><xsl:with-param name="n" select="$startPos + 6"/><xsl:with-param name="all" select="$all"/></xsl:call-template>
    <xsl:call-template name="render-slot"><xsl:with-param name="side" select="$side"/><xsl:with-param name="n" select="$startPos + 7"/><xsl:with-param name="all" select="$all"/></xsl:call-template>
    <xsl:call-template name="render-slot"><xsl:with-param name="side" select="$side"/><xsl:with-param name="n" select="$startPos + 8"/><xsl:with-param name="all" select="$all"/></xsl:call-template>
  </xsl:template>

  <xsl:template name="render-slot">
    <xsl:param name="side"/>
    <xsl:param name="n"/>
    <xsl:param name="all"/>
    <xsl:call-template name="process-index">
      <xsl:with-param name="all" select="$all"/>
      <xsl:with-param name="idx" select="$n"/>
      <xsl:with-param name="side" select="$side"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="process-index">
    <xsl:param name="all"/>
    <xsl:param name="idx"/>
    <xsl:param name="side"/>
    <xsl:choose>
      <xsl:when test="not($all)">
        <div class="card back" style="background-color: #fff; border-color: #ddd;"></div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="first" select="$all[1]"/>
        <xsl:variable name="c">
          <xsl:choose>
            <xsl:when test="string-length(normalize-space($first/@count)) &gt; 0"><xsl:value-of select="number($first/@count)"/></xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="number($idx) &lt;= number($c)">
            <xsl:choose>
              <xsl:when test="$side='front'">
                <xsl:call-template name="render-card-front"><xsl:with-param name="cardNode" select="$first"/></xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="render-card-back"><xsl:with-param name="cardNode" select="$first"/></xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="process-index">
              <xsl:with-param name="all" select="$all[position() &gt; 1]"/>
              <xsl:with-param name="idx" select="$idx - $c"/>
              <xsl:with-param name="side" select="$side"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="render-card-front">
    <xsl:param name="cardNode"/>
    <xsl:choose>
      
      <xsl:when test="local-name($cardNode) = 'atom'">
        <div class="card atom-card">
          <div class="atom-weight"><xsl:value-of select="$cardNode/weight"/></div>
          
          <div class="atom-core">
            <div class="atom-nucleus" style="background-color: {$cardNode/color}; color: {$cardNode/textColor};">
              <xsl:value-of select="$cardNode/symbol"/>
            </div>
            <div class="valence-container e-count-{$cardNode/valence_electrons}">
              <xsl:call-template name="generate-electrons">
                <xsl:with-param name="count" select="$cardNode/valence_electrons"/>
              </xsl:call-template>
            </div>
          </div>
          
          <div class="atom-meta">
            <div class="atom-name"><xsl:value-of select="$cardNode/name"/></div>
          </div>
        </div>
      </xsl:when>

      <xsl:when test="local-name($cardNode) = 'molecule'">
        <div class="card molecule-card">
          <div class="molecule-header">
            <div class="molecule-title"><xsl:value-of select="$cardNode/title"/></div>
            <div class="molecule-points"><xsl:value-of select="$cardNode/points"/> pts</div>
          </div>
          
          <div class="molecule-art">
            <xsl:if test="string-length($cardNode/image) &gt; 0">
              <img src="{$cardNode/image}" style="width:100%; height:100%; object-fit:contain;" alt="Structure"/>
            </xsl:if>
          </div>
          
          <div class="molecule-footer">
            <div class="molecule-formula"><xsl:value-of select="$cardNode/formula"/></div>
            <div class="molecule-lore"><xsl:value-of select="$cardNode/lore"/></div>
          </div>
        </div>
      </xsl:when>
      
    </xsl:choose>
  </xsl:template>

  <xsl:template name="render-card-back">
    <xsl:param name="cardNode"/>
    <xsl:variable name="type" select="local-name($cardNode)"/>
    
    <div class="card back">
      <div class="back-banner top">
        <xsl:choose>
          <xsl:when test="$type='atom'">Prvek</xsl:when>
          <xsl:otherwise>Molekula</xsl:otherwise>
        </xsl:choose>
      </div>
      
      <div class="back-logo">
        <xsl:choose>
          <xsl:when test="$type='atom'">⚛</xsl:when>
          <xsl:otherwise>🧪</xsl:otherwise>
        </xsl:choose>
      </div>
      
      <div class="back-banner bottom">
        <xsl:choose>
          <xsl:when test="$type='atom'">Prvek</xsl:when>
          <xsl:otherwise>Molekula</xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>