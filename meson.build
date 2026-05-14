project('pacman-i18n-ko-kp', version: '1.0.0')

i18n = import('i18n')

domains = [
    'libalpm',
    'pacman',
    'pacman-scripts'
]

foreach domain : domains
    # Meson's i18n.gettext usually expects the po file to be named [lang].po
    # and it creates [domain].mo.
    # Since our files are [domain].[lang].po, we might need a custom approach
    # or just rename them in our repo to follow standard gettext structure
    # if we want to use the high-level i18n module easily.
    # But for a single language, custom_target is often simpler and more explicit.
    
    input_po = join_paths('po', domain + '.ko_KP.po')
    output_mo = domain + '.mo'
    
    custom_target(
        domain + '-mo',
        input: input_po,
        output: output_mo,
        command: [
            find_program('msgfmt'),
            '-o', '@OUTPUT@',
            '@INPUT@'
        ],
        install: true,
        install_dir: join_paths(get_option('datadir'), 'locale', 'ko_KP', 'LC_MESSAGES')
    )
endforeach
