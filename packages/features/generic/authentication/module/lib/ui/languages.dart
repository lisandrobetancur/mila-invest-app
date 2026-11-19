/// Traducciones de authentication, por idioma.
const Map<String, Map<String, Object?>> authenticationLanguages =
    <String, Map<String, Object?>>{
      'es': <String, Object?>{
        'auth': <String, Object?>{
          'common': <String, Object?>{
            'simulated': 'Simulado',
            'disclaimer':
                'Simulación con fines educativos. No es asesoría financiera.',
            'back': 'Volver',
            'show_password': 'Mostrar contraseña',
            'hide_password': 'Ocultar contraseña',
          },
          'login': <String, Object?>{
            'title': 'Inicia sesión',
            'subtitle': 'Practica inversiones con dinero virtual.',
            'email': 'Correo',
            'password': 'Contraseña',
            'submit': 'Iniciar sesión',
            'demo': 'Usar cuenta demo',
            'no_account': '¿No tienes cuenta?',
            'register': 'Crear cuenta',
          },
          'register': <String, Object?>{
            'title': 'Crea tu cuenta',
            'country_title': '¿Desde qué país simulas?',
            'country_co': 'Colombia',
            'country_mx': 'México',
            'country_pe': 'Perú',
            'name': 'Nombre completo',
            'email': 'Correo',
            'document_type': 'Tipo de documento',
            'document_number': 'Número de documento',
            'document_cc': 'Cédula de ciudadanía',
            'document_ce_co': 'Cédula de extranjería',
            'document_ce_pe': 'Carné de extranjería',
            'document_curp': 'CURP',
            'document_dni': 'DNI',
            'password': 'Contraseña',
            'requirement_length': 'Al menos 8 caracteres',
            'requirement_letter': 'Al menos una letra',
            'requirement_number': 'Al menos un número',
            'requirement_met': 'cumplido',
            'requirement_pending': 'pendiente',
            'accept':
                'Entiendo que MILA Invest es una simulación con dinero '
                'virtual y no es asesoría financiera.',
            'submit': 'Crear cuenta',
            'have_account': '¿Ya tienes cuenta?',
            'login': 'Inicia sesión',
          },
          'error': <String, Object?>{
            'invalid_credentials':
                'El correo o la contraseña no coinciden. Revísalos e '
                'inténtalo de nuevo.',
            'email_taken':
                'Ya existe una cuenta con este correo. Inicia sesión o usa '
                'otro.',
            'document_taken': 'Ya existe una cuenta con este documento.',
            'validation': 'Revisa los campos marcados.',
            'rate_limited':
                'Hiciste muchos intentos. Espera un momento y vuelve a '
                'intentar.',
            'network':
                'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo.',
            'unexpected':
                'Recibimos una respuesta inesperada. Inténtalo más tarde.',
            'unknown': 'Algo salió mal. Inténtalo de nuevo.',
          },
          'field_error': <String, Object?>{
            'email_invalid': 'Escribe un correo válido, sin espacios.',
            'password_required': 'Escribe tu contraseña.',
            'password_invalid':
                'Usa al menos 8 caracteres, con una letra y un número.',
            'name_invalid': 'Escribe tu nombre completo (3 a 80 caracteres).',
            'country_required': 'Elige tu país.',
            'document_type_required': 'Elige el tipo de documento.',
            'document_cc_invalid': 'La cédula tiene de 6 a 10 dígitos.',
            'document_ce_invalid':
                'Revisa el número: solo letras y números, sin espacios.',
            'document_curp_invalid':
                'El CURP tiene 18 caracteres, como MAGL850315HDFRRS09.',
            'document_dni_invalid': 'El DNI tiene exactamente 8 dígitos.',
            'accept_required': 'Tienes que aceptar el aviso para continuar.',
            'invalid_format': 'El formato no es válido.',
            'too_weak': 'La contraseña es muy débil.',
            'invalid_length': 'El largo no es válido.',
            'required': 'Este campo es obligatorio.',
            'invalid': 'Revisa este campo.',
          },
        },
      },
      'en': <String, Object?>{
        'auth': <String, Object?>{
          'common': <String, Object?>{
            'simulated': 'Simulated',
            'disclaimer':
                'Simulation for educational purposes. Not financial advice.',
            'back': 'Back',
            'show_password': 'Show password',
            'hide_password': 'Hide password',
          },
          'login': <String, Object?>{
            'title': 'Log in',
            'subtitle': 'Practice investing with virtual money.',
            'email': 'Email',
            'password': 'Password',
            'submit': 'Log in',
            'demo': 'Use demo account',
            'no_account': 'No account yet?',
            'register': 'Create account',
          },
          'register': <String, Object?>{
            'title': 'Create your account',
            'country_title': 'Which country are you simulating from?',
            'country_co': 'Colombia',
            'country_mx': 'Mexico',
            'country_pe': 'Peru',
            'name': 'Full name',
            'email': 'Email',
            'document_type': 'ID type',
            'document_number': 'ID number',
            'document_cc': 'Citizenship ID',
            'document_ce_co': 'Foreigner ID',
            'document_ce_pe': 'Foreigner card',
            'document_curp': 'CURP',
            'document_dni': 'DNI',
            'password': 'Password',
            'requirement_length': 'At least 8 characters',
            'requirement_letter': 'At least one letter',
            'requirement_number': 'At least one number',
            'requirement_met': 'done',
            'requirement_pending': 'pending',
            'accept':
                'I understand MILA Invest is a simulation with virtual money '
                'and not financial advice.',
            'submit': 'Create account',
            'have_account': 'Already have an account?',
            'login': 'Log in',
          },
          'error': <String, Object?>{
            'invalid_credentials':
                'The email or password does not match. Check them and try '
                'again.',
            'email_taken':
                'An account with this email already exists. Log in or use '
                'another one.',
            'document_taken': 'An account with this ID already exists.',
            'validation': 'Check the highlighted fields.',
            'rate_limited': 'Too many attempts. Wait a moment and try again.',
            'network':
                'We could not connect. Check your connection and try again.',
            'unexpected': 'We got an unexpected response. Try again later.',
            'unknown': 'Something went wrong. Try again.',
          },
          'field_error': <String, Object?>{
            'email_invalid': 'Enter a valid email, without spaces.',
            'password_required': 'Enter your password.',
            'password_invalid':
                'Use at least 8 characters, with a letter and a number.',
            'name_invalid': 'Enter your full name (3 to 80 characters).',
            'country_required': 'Choose your country.',
            'document_type_required': 'Choose the ID type.',
            'document_cc_invalid': 'The ID has 6 to 10 digits.',
            'document_ce_invalid':
                'Check the number: letters and digits only, no spaces.',
            'document_curp_invalid':
                'The CURP has 18 characters, like MAGL850315HDFRRS09.',
            'document_dni_invalid': 'The DNI has exactly 8 digits.',
            'accept_required': 'You need to accept the notice to continue.',
            'invalid_format': 'The format is not valid.',
            'too_weak': 'The password is too weak.',
            'invalid_length': 'The length is not valid.',
            'required': 'This field is required.',
            'invalid': 'Check this field.',
          },
        },
      },
    };
