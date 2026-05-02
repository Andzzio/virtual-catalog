def get_checkout_html(form_token: str, public_key: str) -> str:
    return f"""<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pasarela de Pagos | Izipay</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://static.micuentaweb.pe/static/js/krypton-client/V4.0/stable/kr-payment-form.min.js"
        kr-public-key="{public_key}"
        kr-post-url-success="javascript:showSuccessScreen();">
    </script>
    <link rel="stylesheet" href="https://static.micuentaweb.pe/static/js/krypton-client/V4.0/ext/classic.css">
    <style>
        body {{
            margin: 0;
            padding: 0;
            font-family: 'Inter', sans-serif;
            background-color: #F3F5F9;
            color: #333;
            display: flex;
            flex-direction: column;
            align-items: center;
            min-height: 100vh;
        }}
        .izipay-header {{
            width: 100%;
            background-color: #FFFFFF;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            padding: 15px 0;
            text-align: center;
            margin-bottom: 40px;
        }}
        .izipay-header img {{
            height: 35px;
        }}
        .payment-container {{
            background: #FFFFFF;
            border-radius: 12px;
            box-shadow: 0 8px 30px rgba(0,0,0,0.08);
            width: 100%;
            max-width: 450px;
            padding: 40px 30px;
            box-sizing: border-box;
        }}
        .security-badge {{
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            color: #00C3B5;
            font-weight: 600;
            font-size: 15px;
            margin-bottom: 25px;
            padding-bottom: 20px;
            border-bottom: 1px solid #E5E7EB;
        }}
        .security-badge svg {{
            width: 18px;
            height: 18px;
        }}
        .kr-embedded {{
            width: 100% !important;
            background: transparent !important;
            box-shadow: none !important;
            border: none !important;
            padding: 0 !important;
        }}
        .kr-payment-button {{
            background-color: #FF2D46 !important;
            color: #FFFFFF !important;
            border-radius: 8px !important;
            font-size: 16px !important;
            font-weight: 600 !important;
            padding: 16px !important;
            transition: background-color 0.2s !important;
        }}
        .kr-payment-button:hover {{
            background-color: #E01E35 !important;
        }}
        .footer-secure {{
            margin-top: 30px;
            text-align: center;
        }}
        .footer-secure img {{
            height: 28px;
            opacity: 0.8;
        }}
        .footer-secure p {{
            font-size: 12px;
            color: #888;
            margin-top: 10px;
        }}
        @media (max-width: 480px) {{
            .izipay-header {{ margin-bottom: 20px; }}
            .payment-container {{
                padding: 25px 20px;
                border-radius: 0;
                box-shadow: none;
                border-top: 1px solid #E5E7EB;
            }}
            body {{ background-color: #FFFFFF; }}
        }}
    </style>
</head>
<body>
    <header class="izipay-header">
        <div style="font-family: Arial, sans-serif; font-weight: 900; font-style: italic; font-size: 28px; letter-spacing: -1px;">
            <span style="color: #0B2B46;">izi</span><span style="color: #FF2D46;">pay</span>
        </div>
    </header>

    <div class="payment-container" id="main-container">
        <div class="security-badge">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
            Checkout 100% Seguro
        </div>

        <div class="kr-embedded" kr-form-token="{form_token}">
            <div class="kr-pan"></div>
            <div class="kr-expiry"></div>
            <div class="kr-security-code"></div>
            <button class="kr-payment-button">PAGAR PEDIDO</button>
            <div class="kr-form-error"></div>
        </div>

        <div class="footer-secure">
            <div style="display: inline-flex; align-items: center; gap: 8px; background: #f3f4f6; padding: 6px 12px; border-radius: 6px; font-weight: bold; color: #4b5563; font-size: 13px; margin-bottom: 8px;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                PCI-DSS CERTIFIED
            </div>
            <p>Tus datos están encriptados y protegidos<br>bajo los máximos estándares de seguridad.</p>
        </div>
    </div>

    <script>
        function showSuccessScreen() {{
            const container = document.getElementById('main-container');
            container.innerHTML = `
                <div style="text-align: center; padding: 20px 10px;">
                    <div style="width: 80px; height: 80px; background: #E8F5E9; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px;">
                        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#2E7D32" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                    </div>
                    <h2 style="color: #1a1a1a; margin-bottom: 8px; font-size: 24px; font-family: 'Inter', sans-serif;">¡Pago Exitoso!</h2>
                    <p style="color: #666; margin-bottom: 30px; font-size: 15px; line-height: 1.5;">Tu transacción ha sido aprobada de forma segura.</p>
                    <p style="color: #888; font-size: 13px; margin-bottom: 20px;">Ya puedes cerrar esta ventana y regresar a la tienda.</p>
                </div>
            `;
        }}
    </script>
</body>
</html>"""
