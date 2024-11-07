from tree_sitter import Parser
from tree_sitter_languages import get_language, get_parser

language = get_language('bash')
parser = get_parser('bash')