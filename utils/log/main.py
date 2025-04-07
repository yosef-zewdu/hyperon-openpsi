
# from hyperon import *
# from hyperon.ext import register_atoms
# import random
# import string
# import time
# from hyperon.atoms import OperationAtom, V
# from hyperon.ext import register_atoms
# import itertools
# from itertools import combinations


# def print_atom(metta: MeTTa, var1, var2):
#     var7 = "(" + str(var1) + " " + str(var2) + ")"
#     var8 = metta.parse_all(var7)
#     return var8


# @register_atoms(pass_metta=True)
# def main(metta):
#     printer_var = OperationAtom(
#         "printer",
#         lambda var1, var2: print_atom(metta, var1, var2),
#         ["Atom", "Atom", "Expression"],
#         unwrap=False,
#     )

#     return {r"printer": printer_var}


# log/event_logger.py

import logging
import sys
from hyperon import *
from hyperon.ext import register_atoms
from hyperon.atoms import OperationAtom, GroundedAtom, SymbolAtom, ValueAtom

# --- Configuration ---
LOG_FILE_NAME = 'metta_events.log'
LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
CONSOLE_LOG_LEVEL = logging.DEBUG  # Log DEBUG and higher to console
FILE_LOG_LEVEL = logging.INFO     # Log INFO and higher to file
LOGGER_NAME = 'MeTTaLogger'
# ---------------------

# --- Setup Python Logger ---
logger = logging.getLogger(LOGGER_NAME)
logger.setLevel(logging.DEBUG) # Set lowest level to capture all messages

# --- Console Handler ---
console_handler = logging.StreamHandler(sys.stdout) # Log to standard output
console_handler.setLevel(CONSOLE_LOG_LEVEL)
console_formatter = logging.Formatter(LOG_FORMAT)
console_handler.setFormatter(console_formatter)
if not any(isinstance(h, logging.StreamHandler) for h in logger.handlers): # Avoid adding handlers multiple times
    logger.addHandler(console_handler)

    # --- File Handler ---
    try:
        file_handler = logging.FileHandler(LOG_FILE_NAME)
        file_handler.setLevel(FILE_LOG_LEVEL)
        file_formatter = logging.Formatter(LOG_FORMAT)
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
        logger.info(f"--- Logger initialized. Logging to console (level {logging.getLevelName(CONSOLE_LOG_LEVEL)}) and file '{LOG_FILE_NAME}' (level {logging.getLevelName(FILE_LOG_LEVEL)}) ---")
    except Exception as e:
        logger.error(f"Failed to initialize file handler for {LOG_FILE_NAME}: {e}")
        print(f"ERROR: Failed to initialize file handler for {LOG_FILE_NAME}: {e}", file=sys.stderr)

# --- Event Handlers (Extensible Part) ---
# Handlers now just format the message string based on arguments

def format_modulator_change(name: str, old_value: str, new_value: str) -> str:
    """Formats the log message for modulator changes."""
    return f"Modulator Change: Name='{name}', Old='{old_value}', New='{new_value}'"

# Add more handlers here as needed, they should return a string message
# def format_user_action(user_id: str, action: str) -> str:
#     return f"User Action: User='{user_id}', Action='{action}'"

# --- Mapping Event Types to Handlers and Default Levels ---
# Structure: "event_type": (handler_function, default_logging_level)
EVENT_HANDLERS = {
    "modulator_change": (format_modulator_change, logging.INFO),
    "modulator_debug": (format_modulator_change, logging.DEBUG), # Example: same formatter, different level
    # "user_action": (format_user_action, logging.WARNING), # Example for future extension
}

# --- MeTTa Integration ---

def log_event_atom_execute(metta: MeTTa, event_type_atom: Atom, *args: Atom):
    """
    MeTTa operation function to dispatch logging events.
    Level is determined internally based on event_type.
    Expects:
    1. event_type (SymbolAtom): String identifying the handler (e.g., 'modulator_change').
    2. *args (Atom...): Specific arguments for the handler.
    """
    try:
        # Extract event type (must be a Symbol)
        if not isinstance(event_type_atom, SymbolAtom):
            logger.error(f"log-event: Expected Symbol for event_type, got {type(event_type_atom)}: {event_type_atom}")
            return [] # Return empty result on error
        event_type = event_type_atom.get_name()

        # Find the correct handler and its default level
        handler_info = EVENT_HANDLERS.get(event_type)
        if handler_info is None:
            logger.error(f"log-event: No handler found for event type '{event_type}'")
            return []

        formatter_func, default_level = handler_info

        # Convert remaining MeTTa atoms to Python strings for simplicity
        handler_args = [str(arg) for arg in args]

        # Call the specific formatter function to get the message
        try:
            message = formatter_func(*handler_args)
        except TypeError as te:
             # Error likely due to wrong number of arguments passed from MeTTa
             expected_args_count = formatter_func.__code__.co_argcount
             logger.error(f"log-event: Formatter for '{event_type}' called with incorrect number of arguments. Expected {expected_args_count}, Got {len(handler_args)}. MeTTa args: {args}. Error: {te}")
             return []
        except Exception as e:
            logger.error(f"log-event: Error executing formatter for '{event_type}': {e}")
            return []

        # Log the message using the determined level
        logger.log(default_level, message)

        # Return empty expression '()' to indicate successful execution of side-effect
        return [] # Changed from previous version, [] represents ()

    except Exception as e:
        logger.error(f"log-event: Unexpected error processing log event: {e}")
        return [] # Return empty on unexpected errors

@register_atoms(pass_metta=True)
def register_logger_atoms(metta):
    """Registers the log-event operation atom."""
    log_event_atom = OperationAtom(
        "log-event",
        # Lambda now only takes event_type and *args
        lambda event_type, *args: log_event_atom_execute(metta, event_type, *args),
        # Type signature updated: Symbol, then variable arguments
        ["Atom", "Expression", "Expression"],
        unwrap=False, # We need to handle Atom types directly
    )
    logger.info("`log-event` operation registered for MeTTa.")
    return {"log-event": log_event_atom}